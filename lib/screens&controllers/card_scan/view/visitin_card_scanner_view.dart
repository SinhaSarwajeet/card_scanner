import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../utils/gradient_text.dart';
import '../controller/card_controller.dart';
import 'package:get/get.dart';
import 'extract_image_view.dart';
import 'saved_cards_view.dart';

class VisitingCardScannerView extends StatelessWidget {
  VisitingCardScannerView({super.key});

  final CardController cardController = Get.find();
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const GradientText("Scan", style: TextStyle(fontSize: 12), gradient: LinearGradient(colors: [Colors.blue, Colors.pink])),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child:  Image.asset("assets/images/scan.png", width: 125,),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GradientText("Scan from Gallery", style: TextStyle(fontSize: 12), gradient: LinearGradient(colors: [Colors.blue, Colors.pink])),
                        const SizedBox(height: 5,),
                        Image.asset("assets/images/gallery.png", width: 120,),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  GestureDetector(
                    onTap: () => Get.to(SavedCardsView()), // Navigate to saved cards screen
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.pink],
                      ),
                    ),
                      child: Container(
                        decoration:  BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                          ),
                        margin: const EdgeInsets.all(1),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: const GradientText(
                          'Saved Cards',
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.pink,
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
