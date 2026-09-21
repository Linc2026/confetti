import 'package:get/get.dart';
import 'confetti_countdown_logic.dart';
class ConfettiCountdownBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiCountdownLogic());
  }
}
