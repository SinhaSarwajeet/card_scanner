import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scancard/screens&controllers/card_scan/view/saved_cards_view.dart';
import '../controller/card_controller.dart';

class ExtractCardView extends StatelessWidget {

  ExtractCardView({super.key});

  final CardController cardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extract Card Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                // Display the picked image
                if (cardController.image.value == null) {
                  return const Text('No image selected.');
                }
                return Image.file(cardController.image.value!);
              }),
              const SizedBox(height: 20),

              // Extract button or processing/loading indicator
              Obx(() {
                if (cardController.isProcessing.value) {
                  return const CircularProgressIndicator();
                } else if (cardController.extractedCardDetails.value == null) {
                  // Show extract button if extraction is not done
                  return ElevatedButton(
                    onPressed: _extractDetails,
                    child: const Text('Extract Details'),
                  );
                } else {
                  // After successful extraction, show card details
                  return const SizedBox.shrink();
                }
              }),

              const SizedBox(height: 20),

              // Show extracted details or error message
              Obx(() {
                if (cardController.errorMessage.isNotEmpty) {
                  return Text(
                    cardController.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  );
                }
                else if (cardController.extractedCardDetails.value != null) {
                  final card = cardController.extractedCardDetails.value!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${card.name ?? 'No Name'}'),
                      Text('Phone: ${card.phone ?? 'No Phone'}'),
                      Text('Email: ${card.email ?? 'No Email'}'),
                      Text('Address: ${card.address ?? 'No Address'}'),
                    ],
                  );
                }
                return const SizedBox.shrink(); // No details to show
              }),

              // Navigate to saved cards button
              ElevatedButton(
                onPressed: () {
                  cardController.extractedCardDetails.value = null;
                  Get.off(SavedCardsView());
                  }, // Navigate to saved cards screen
                child: const Text('View Saved Cards'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extract card details method
  void _extractDetails() async {
    await cardController.processImageForOCR();
  }
}
