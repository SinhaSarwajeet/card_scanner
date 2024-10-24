import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scancard/screens&controllers/splash/splash_controller.dart';


class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashController splashController = Get.find();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarIconBrightness: Brightness.dark,systemNavigationBarColor: Colors.black, statusBarIconBrightness: Brightness.light));
    splashController.loadSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue, Colors.pink], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: const Center(child: Text("CardScan", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 40, fontStyle: FontStyle.italic),)),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
