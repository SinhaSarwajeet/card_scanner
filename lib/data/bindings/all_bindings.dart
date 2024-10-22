import 'package:get/get.dart';
import 'package:scancard/screens&controllers/card_scan/controller/card_controller.dart';

class AllBindings{
  static initialize()async{
    Get.lazyPut<CardController>(()=>CardController(),fenix: true);
  }
}