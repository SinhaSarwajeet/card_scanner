import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scancard/screens&controllers/card_scan/view/saved_cards_view.dart';
import 'package:scancard/utils/contact_card.dart';
import 'package:scancard/utils/gradient_text.dart';
import '../controller/card_controller.dart';

class ExtractCardView extends StatelessWidget {

  ExtractCardView({super.key});

  final CardController cardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Extract Card Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    return GestureDetector(
                      onTap: extractDetails,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue, Colors.pink]),
                          borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        child: Container(
                            margin: const EdgeInsets.all(1),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12))
                            ),
                            child: const GradientText(
                                "Extract details",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                ),
                                gradient: LinearGradient(
                                    colors: [Colors.blue, Colors.pink],
                                ),
                            ),
                        ),
                      ),
                    );
                  } else {
                    // After successful extraction, show card details
                    return const SizedBox.shrink();
                  }
                }
                ),

                const SizedBox(height: 20),
                // Show extracted details or error message
                Obx(() {
                  if (cardController.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        cardController.errorMessage.value,
                        textAlign:TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  else if (cardController.extractedCardDetails.value != null) {
                    final card = cardController.extractedCardDetails.value!;
                    return ContactCard(name: card.name??"Name", phone: card.phone??"Phone", email: card.email??"Email");
                  }
                  return const SizedBox.shrink(); // No details to show
                }),

                // Navigate to saved cards button
                GestureDetector(
                  onTap: ()=>Get.off(()=>SavedCardsView()),
                  child: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.pink]),
                        borderRadius: BorderRadius.all(Radius.circular(12),
                        ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12),
                          ),
                      ),
                      child: const GradientText(
                        "Saved Cards",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.pink],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extract card details method
  void extractDetails() async {
    await cardController.processImageForOCR();
  }
}
