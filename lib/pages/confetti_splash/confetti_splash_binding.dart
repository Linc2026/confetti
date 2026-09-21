import 'package:get/get.dart';
import 'confetti_splash_logic.dart';
class ConfettiSplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConfettiSplashLogic>()) {
      Get.put(ConfettiSplashLogic());
    }
  }
}
