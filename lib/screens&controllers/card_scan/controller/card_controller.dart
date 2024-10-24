import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scancard/main.dart';
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
    /// This function processes an image using OCR to extract text and identify card details such as name, phone, and email.
    /// It first ensures an image is selected. If no image is selected, an error is set.
    /// The extracted card details and any previous errors are cleared before processing starts.
    /// The image is processed with OCR, and the recognized text is extracted.
    /// If no text is detected, an error is shown, and the process is halted.
    /// The function uses the extracted text to detect card details (name, phone, and email).
    /// Before saving the extracted details, it checks if a card with the same phone or email already exists in the `savedCards` list.
    /// If a match is found, the existing card is updated with the new details. Otherwise, a new card is added to the saved cards.
    /// The extracted details are finally stored in the `extractedCardDetails` variable for further use.

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
        // Check if a card with the same phone or email already exists in savedCards
        CardDetails? existingCard;
        for (var card in savedCards) {
          if (card.phone == cardDetails.phone || card.email == cardDetails.email) {
            existingCard = card;
            break;
          }
        }

        if (existingCard != null) {
          // If an existing card is found, update its details
          existingCard.name = cardDetails.name;
          existingCard.phone = cardDetails.phone;
          existingCard.email = cardDetails.email;
          // You could also update other fields like address, designation, etc. if needed
        } else {
          // No existing card found, add as a new card
          addCard(cardDetails); // Save extracted card details
        }

        // Successfully extracted details, save them
        extractedCardDetails.value = cardDetails; // Update current details
      }
    } catch (e) {
      setError('Error processing image. Please try again with a clearer image.');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<CardDetails?> extractDetailsFromText(String text) async {
    /// This function processes a block of text (OCR result) to extract card details like name, phone, and email.
    /// It uses regular expressions to identify phone numbers and email addresses.
    /// The first text line that does not match a phone or email pattern is assumed to be the name.
    /// After extracting these details, it checks if a card with the same phone or email already exists in the savedCards list.
    /// If a duplicate is found, it shows a dialog asking the user whether to overwrite the existing card or not.
    /// A dialog is also shown to the user for confirming and editing the detected details before saving.
    /// The function returns a `CardDetails` object if extraction and saving are successful, otherwise it returns null.


    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    String? extractedName;
    String? extractedPhone;
    String? extractedEmail;

    // Detect email and phone using regex
    for (String line in lines) {
      if (emailRegex.hasMatch(line) && extractedEmail == null) {
        extractedEmail = emailRegex.firstMatch(line)?.group(0);
      }
      if (phoneRegex.hasMatch(line) && extractedPhone == null) {
        extractedPhone = phoneRegex.firstMatch(line.replaceAll(" ", ''))?.group(0);
      }
    }

    // Detect the name (assuming it's the first line or one of the early lines)
    for (String line in lines) {
      if (!emailRegex.hasMatch(line) && !phoneRegex.hasMatch(line)) {
        extractedName = line; // Assuming this line is the name, can refine this logic based on patterns
        break;
      }
    }

    // Check if essential details (phone, email, name) are detected
    if (extractedEmail == null || extractedPhone == null || extractedName == null) {
      setError("Failed to detect name, phone, or email. Please try again with a clearer image.");
      return null;
    }

    // Check if phone or email is already present in saved cards
    bool cardAlreadyExists = savedCards.any((card) =>
    (card.phone == extractedPhone) || (card.email == extractedEmail));

    // If card already exists, show overwrite confirmation dialog
    if (cardAlreadyExists) {
      bool overwrite = false;

      await showDialog(
        context: MyApp.navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Card Already Exists"),
            content: const Text("A card with the same phone or email already exists. Do you want to overwrite the existing card?"),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.back(); // Close the dialog
                },
                child: const Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.w600),),
              ),
              const SizedBox(width: 20,),
              GestureDetector(
                onTap: () {
                  overwrite = true;
                  Get.back(); // Close the dialog and allow overwriting
                },
                child: const Text("Overwrite", style: TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.w600),),
              ),
            ],
          );
        },
      );

      if (!overwrite) {
        // If the user chooses not to overwrite, return null
        return null;
      }
    }

    // Show dialog to confirm and edit detected details
    Future<void> showDetailsEditDialog({
      required BuildContext context,
      required String name,
      required String phone,
      required String email,
      required Function(String, String, String) onSave,
    }) async {
      final TextEditingController nameController = TextEditingController(text: name);
      final TextEditingController phoneController = TextEditingController(text: phone);
      final TextEditingController emailController = TextEditingController(text: email);

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm and Edit Details",),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.w600),),
              ),
              const SizedBox(width: 20,),
              GestureDetector(
                onTap: () {
                  // Complete and save the card details
                  onSave(nameController.text, phoneController.text, emailController.text);
                  Get.back();
                },
                child: const Text("Save", style: TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.w600),),
              ),
            ],
          );
        },
      );
    }

    // Show the edit dialog for confirmation and changes
    bool savePressed = false;
    await showDetailsEditDialog(
      context: MyApp.navigatorKey.currentContext!,
      name: extractedName,
      phone: extractedPhone,
      email: extractedEmail,
      onSave: (name, phone, email) {
        extractedName = name;
        extractedPhone = phone;
        extractedEmail = email;
        savePressed = true;
      },
    );

    // If Save is not pressed, return null
    if (!savePressed) {
      return null;
    }

    // Return the card details only if save is pressed
    return CardDetails(
      name: extractedName,
      phone: extractedPhone,
      email: extractedEmail,
      address: null, // Address not handled
      designation: null,
      company: null,
    );
  }



}