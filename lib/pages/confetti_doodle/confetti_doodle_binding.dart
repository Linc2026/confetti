import 'package:get/get.dart';
import 'confetti_doodle_logic.dart';
class ConfettiDoodleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiDoodleLogic());
  }
}
