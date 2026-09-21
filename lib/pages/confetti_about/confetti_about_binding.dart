import 'package:get/get.dart';
import 'confetti_about_logic.dart';
class ConfettiAboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiAboutLogic());
  }
}
