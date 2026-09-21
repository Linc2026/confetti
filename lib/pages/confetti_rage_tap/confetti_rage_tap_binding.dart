import 'package:get/get.dart';
import 'confetti_rage_tap_logic.dart';
class ConfettiRageTapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiRageTapLogic());
  }
}
