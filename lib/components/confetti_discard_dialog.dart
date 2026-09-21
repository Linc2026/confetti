import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ConfettiDiscardDialog {
  static Future<void> show({
    required String title,
    required String content,
    required VoidCallback onDiscard,
  }) async {
    if (Get.isDialogOpen == true) return;
    await Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFFFFFCF9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B5E56)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9E8E84)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onDiscard();
            },
            child: const Text(
              'Discard',
              style: TextStyle(
                color: Color(0xFFE85A42),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
