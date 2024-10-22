// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scancard/screens&controllers/card_scan/controller/card_controller.dart';
import 'package:scancard/screens&controllers/card_scan/view/extract_image_view.dart';
import 'package:scancard/screens&controllers/card_scan/view/saved_cards_view.dart';
import 'package:scancard/screens&controllers/card_scan/view/visitin_card_scanner_view.dart';


void main() async{
   Get.lazyPut(()=>CardController(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Visiting Card Scanner',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => VisitingCardScannerView()),
        GetPage(name: '/extract-image', page: () => ExtractCardView()),
        GetPage(name: '/saved-cards', page: () => SavedCardsView()),
      ],
    );
  }
}
