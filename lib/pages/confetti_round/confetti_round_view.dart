import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'confetti_round_logic.dart';

class ConfettiRoundView extends GetView<ConfettiRoundLogic> {
  const ConfettiRoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.jngmclr.value
              ? const CircularProgressIndicator(color: Colors.black)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.aghkzbr();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
