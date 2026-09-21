import 'package:get/get.dart';

import 'confetti_round_logic.dart';

class ConfettiRoundBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      ConfettiRoundLogic(),
      permanent: true,
    );
  }
}
