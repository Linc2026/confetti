import 'package:get/get.dart';
import 'confetti_write_logic.dart';
class ConfettiWriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiWriteLogic());
  }
}
