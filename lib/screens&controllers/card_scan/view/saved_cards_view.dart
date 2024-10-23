import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/contact_card.dart';
import '../controller/card_controller.dart';
//this screen shows all the saved cards
class SavedCardsView extends StatelessWidget {

  SavedCardsView({super.key});

  final CardController cardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cards'),
      ),
      body: Obx(() {
        if (cardController.savedCards.isEmpty) {
          return const Center(child: Text('No saved cards.'));
        }
        return ListView.builder(
          itemCount: cardController.savedCards.length,
          itemBuilder: (context, index) {
            final card = cardController.savedCards[index];
            return ContactCard(name: card.name??"Name", phone: card.phone??"Phone", email: card.email??"Email");
          },
        );
      }),
    );
  }
}
