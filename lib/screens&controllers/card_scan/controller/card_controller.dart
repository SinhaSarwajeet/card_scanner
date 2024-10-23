import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scancard/main.dart';
import 'package:scancard/utils/gradient_text.dart';
import '../../../data/local storage/shared_prefrences.dart';
import '../../../data/model/card_detail_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../utils/regx.dart';

class CardController extends GetxController {
  var savedCards = <CardDetails>[].obs;
  var isProcessing = false.obs;
  var errorMessage = ''.obs;
  Rxn<File> image = Rxn(null);  // Picked image
  Rxn<CardDetails> extractedCardDetails = Rxn(null);  // Extracted details for the current card

  final SharedPreferencesService _prefsService = SharedPreferencesService();

  @override
  void onInit() {
    super.onInit();
    loadSavedCards();
  }

  void addCard(CardDetails card) {
    savedCards.insert(0, card);
    _prefsService.saveCards(savedCards);
  }

  Future<void> loadSavedCards() async {
    var cards = await _prefsService.loadCards();
    savedCards.assignAll(cards);
  }

  void clearError() {
    errorMessage.value = '';
  }

  void setError(String message) {
    errorMessage.value = message;
  }

  Future<void> processImageForOCR() async {
    if (image.value == null) {
      setError('No image selected.');
      return;
    }

    // Clear previous card details and error before processing

    extractedCardDetails.value = null;
    errorMessage.value = '';

    isProcessing.value = true;
    try {
      final inputImage = InputImage.fromFile(image.value!);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      final extractedText = recognizedText.text;

      if (extractedText.isEmpty) {
        setError('No text detected. Please try again with a clearer image.');
        return; // Stop if extraction fails
      }

      final cardDetails = await extractDetailsFromText(extractedText);
      if (cardDetails != null) {
        // Successfully extracted details, save them
        extractedCardDetails.value = cardDetails; // Update current details
        addCard(cardDetails); // Save extracted card details automatically
      }
    } catch (e) {
      setError('Error processing image. Please try again with a clearer image.');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<CardDetails?> extractDetailsFromText(String text) async {
    /// This function takes the extracted text from an image and processes it to
    /// retrieve the card details such as name, phone, and email. It uses regex
    /// to detect phone numbers and emails, and shows a dialog to the user to
    /// select the name if available.
    ///
    /// The function performs the following steps:
    /// 1. Split the extracted text into individual lines and filter out empty ones.
    /// 2. Attempt to extract phone number and email from the text using regex.
    /// 3. If either the phone or email is not found, it sets an error message
    ///    and returns `null`.
    /// 4. If phone and email are found, it prompts the user with a dialog to
    ///    select the name from the text lines.
    /// 5. If no valid name is selected, it sets an error message and returns `null`.
    /// 6. If valid name, phone, and email are found, it returns a `CardDetails`
    ///    object containing the extracted information.
    ///
    /// Parameters:
    /// - `text`: The raw text extracted from the visiting card image.
    ///
    /// Returns:
    /// - A `Future<CardDetails?>` containing the extracted details if successful,
    ///   or `null` if any required information is missing The required informations are name, email and phone.
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    String? selectedName;
    String? extractedPhone;
    String? extractedEmail;

    // Extract email and phone from text using regex
    for (String line in lines) {
      if (emailRegex.hasMatch(line) && extractedEmail == null) {
        extractedEmail = emailRegex.firstMatch(line)?.group(0);
      }
      if (phoneRegex.hasMatch(line) && extractedPhone == null) {
        extractedPhone = phoneRegex.firstMatch(line.replaceAll(" ", ''))?.group(0);
      }
    }
    if(extractedEmail == null || extractedPhone == null){
      setError("Phone/email or both were not found, choose clearer image.");
      return null;
    }

    Future<void> showNameSelectionDialog({
      required BuildContext context,
      required List<String> options,
      required ValueChanged<String?> onCompleted,
    }) async {
      String? selectedOption;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    child: const Column(
                      children: [
                        GradientText(
                          'Select Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          gradient:
                              LinearGradient(colors: [Colors.blue, Colors.pink]),
                        ),
                        SizedBox(height: 10,),
                        Text("Email and phone have been detected automatically, please choose name from the options. Choosing an option is necessary to enable save button.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                      ],
                    ),
                ),
                content: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...options.map((option) => ListTile(
                          selectedTileColor: Colors.grey.withOpacity(0.3),
                          title: Text(option),
                          onTap: () {
                            setState(() {
                              selectedOption = option;
                            });
                          },
                          selected: selectedOption == option,
                        ),
                        ),
                        ListTile(
                          selectedTileColor: Colors.grey.withOpacity(0.3),
                          title: const Text('None'),
                          onTap: () {
                            setState(() {
                              selectedOption = '';
                            });
                          },
                          selected: selectedOption == '',
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Column(
                    children: [
                      const Text("Tap cancel button twice to dismiss this Dialog box. But, on cancelling, no card details will be saved.", style: TextStyle(color:  Colors.indigo),),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onDoubleTap: ()=>Get.back(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 20,),
                          GestureDetector(
                            onTap: () {
                              // Complete and close the dialog
                              if(selectedOption?.isNotEmpty == true ) {
                                onCompleted(selectedOption);
                                Get.back();
                              }
                            },
                            child: const GradientText("Save", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), gradient: LinearGradient(colors: [Colors.blue, Colors.pink])),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      );
    }

    // Show dialog only for selecting name
    await showNameSelectionDialog(
      context: MyApp.navigatorKey.currentContext!,
      options: lines,
      onCompleted: (name) {
        selectedName = name;
      },
    );

    // If no valid name is selected return null -> contact won't be saved
    if (selectedName == null) {
      setError('Name not selected. Please try again.');
      return null;
    }

    // Return the extracted and user-selected card details
    return CardDetails(
      name: selectedName?.isNotEmpty == true ? selectedName : null,
      phone: extractedPhone?.isNotEmpty == true ? extractedPhone : null,
      email: extractedEmail?.isNotEmpty == true ? extractedEmail : null,
      address: null, // Address is no longer handled
      designation: null,
      company: null,
    );
  }

}