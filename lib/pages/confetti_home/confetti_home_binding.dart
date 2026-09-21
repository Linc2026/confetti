import 'package:get/get.dart';
import 'confetti_home_logic.dart';
class ConfettiHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiHomeLogic());
  }
}
