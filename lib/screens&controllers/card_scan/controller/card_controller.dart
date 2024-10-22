import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scancard/main.dart';
import 'package:scancard/screens&controllers/card_scan/view/visitin_card_scanner_view.dart';
import '../../../data/local storage/shared_prefrences.dart';
import '../../../data/model/card_detail_model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
    _loadSavedCards();
  }

  void addCard(CardDetails card) {
    savedCards.add(card);
    _prefsService.saveCards(savedCards);
  }

  Future<void> _loadSavedCards() async {
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

  Future<CardDetails?> extractDetailsFromText( String text) async {
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    String? selectedName;
    String? selectedPhone;
    String? selectedEmail;
    String? selectedAddress;
    bool showWarning = false;
    int cancelCount = 0;

    Future<void> showSelectionDialog({
      required BuildContext context,
      required String title,
      required List<String> options,
      required int currentStep,
      required int totalSteps,
      required ValueChanged<String?> onSelected,
    }) async {
      String? selectedOption;
      bool nextPressed = false;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: Text('Select $title from the extracted texts' )),
                    Text('$currentStep of $totalSteps', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                content: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...options.map((option) => ListTile(
                          title: Text(option),
                          onTap: () {
                            setState(() {
                              selectedOption = option;
                            });
                          },
                          selected: selectedOption == option,
                        )),
                        ListTile(
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
                  if (showWarning)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Warning: All fields are not provided, card details will not be saved Press Cancel again to discard.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     TextButton(
                       onPressed: () {
                         if (cancelCount == 0) {
                           // Show warning message in red
                           setState(() {
                             showWarning = true;
                           });
                           cancelCount++;
                         } else {
                           // Second cancel press: dismiss dialog and navigate back to first screen
                           Future.delayed(const Duration(milliseconds: 100), () {
                             isProcessing(false);
                             Get.until((route) => !Get.isDialogOpen!);
                             Get.back();
                            // Ensure it returns to the first screen
                           });
                         }
                       },
                       child: const Text('Cancel'),
                     ),
                     ElevatedButton(
                       onPressed: () {
                         if (selectedOption != null) {
                           onSelected(selectedOption);

                           // Reset warning and cancel count when next is pressed
                           setState(() {
                             showWarning = false;
                             cancelCount = 0;
                           });

                           nextPressed = true;
                           Get.back();// Close the dialog after selecting
                         }
                       },
                       child: const Text('Next'),
                     ),
                   ],
                 )
                ],
              );
            },
          );
        },
      );

      if (nextPressed) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    // Sequentially show dialogs for each field
    await showSelectionDialog(
      context: MyApp.navigatorKey.currentContext!,
      title: 'Name',
      options: lines,
      currentStep: 1,
      totalSteps: 4,
      onSelected: (selected) {
        selectedName = selected;
        lines.remove(selected);
      },
    );

    await showSelectionDialog(
      context: MyApp.navigatorKey.currentContext!,
      title: 'Phone',
      options: lines,
      currentStep: 2,
      totalSteps: 4,
      onSelected: (selected) {
        selectedPhone = selected;
        lines.remove(selected);
      },
    );

    await showSelectionDialog(
      context: MyApp.navigatorKey.currentContext!,
      title: 'Email',
      options: lines,
      currentStep: 3,
      totalSteps: 4,
      onSelected: (selected) {
        selectedEmail = selected;
        lines.remove(selected);
      },
    );

    await showSelectionDialog(
      context: MyApp.navigatorKey.currentContext!,
      title: 'Address',
      options: lines,
      currentStep: 4,
      totalSteps: 4,
      onSelected: (selected) {
        selectedAddress = selected;
        lines.remove(selected);
      },
    );

    // If all fields are empty, show error and return null
    if (selectedName == null && selectedPhone == null && selectedEmail == null && selectedAddress == null) {
      setError('No valid details found. Please try again.');
      return null;
    }

    // Return the extracted and user-selected card details
    return CardDetails(
      name: selectedName?.isNotEmpty == true ? selectedName : null,
      phone: selectedPhone?.isNotEmpty == true ? selectedPhone : null,
      email: selectedEmail?.isNotEmpty == true ? selectedEmail : null,
      address: selectedAddress?.isNotEmpty == true ? selectedAddress : null,
      designation: null,
      company: null,
    );
  }
}