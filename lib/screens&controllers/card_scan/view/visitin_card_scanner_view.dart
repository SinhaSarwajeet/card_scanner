// lib/views/visiting_card_scanner_view.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controller/card_controller.dart';
import 'package:get/get.dart';
import 'extract_image_view.dart';
import 'saved_cards_view.dart'; // Import the saved cards screen

class VisitingCardScannerView extends StatelessWidget {
  VisitingCardScannerView({super.key});

  final CardController cardController = Get.find();
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text('Visiting Card Scanner',),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Capture Card'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Select from Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(SavedCardsView()), // Navigate to saved cards screen
              child: const Text('View Saved Cards'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    cardController.extractedCardDetails.value = null;
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      cardController.image.value = File(pickedFile.path);
      cardController.clearError(); // Clear any previous error message

      // Automatically navigate to the second screen
      Get.to(()=>ExtractCardView());
    }
  }
}
