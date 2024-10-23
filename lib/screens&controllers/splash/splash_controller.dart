import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scancard/screens&controllers/card_scan/view/visitin_card_scanner_view.dart';

class SplashController extends GetxController{
  void loadSplash()async{
    await Future.delayed(const Duration(milliseconds: 2000));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark,systemNavigationBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
    Get.off(()=>VisitingCardScannerView());
  }
}