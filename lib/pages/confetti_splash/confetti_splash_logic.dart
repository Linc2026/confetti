import 'package:get/get.dart';
class ConfettiSplashLogic extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.currentRoute == '/con_splash') {
        Get.offNamed('/con_home');
      }
    });
  }
}
