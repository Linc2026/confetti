import 'package:get/get.dart';
import 'confetti_word_jar_logic.dart';
class ConfettiWordJarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfettiWordJarLogic());
  }
}
