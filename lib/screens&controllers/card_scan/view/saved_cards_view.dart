import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/card_controller.dart';

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
            return ListTile(
              title: Text(card.name ?? 'No Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.phone ?? 'No Phone'),
                  Text(card.email ?? 'No Email'),
                  Text(card.address ?? 'No Address'),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
