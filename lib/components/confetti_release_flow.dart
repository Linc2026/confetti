import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../db_confetti/data.dart';
import '../db_confetti/db_confetti_entity.dart';
import '../models/pen_theme.dart';
import '../models/release_quotes.dart';
import '../utils/index.dart';
import 'confetti_release_overlay.dart';
import 'confetti_shred_fx.dart';
enum ReleasePhase { idle, shredding, done }
mixin ConfettiReleaseMixin on GetxController {
  final releasePhase = ReleasePhase.idle.obs;
  final releaseQuote = ''.obs;
  final releaseInkWeight = 0.obs;
  final releaseMode = ConfettiShredMode.physicalDegradation.obs;
  ImageProvider? releaseBurstImage;
  List<String> releaseWords = const [];
  String? releaseBurstLabel;
  bool _releasing = false;
  String get releaseThemeId => 'crispyBlank';
  String get releasePaperImage => kPenThemes.first.paperImage;
  Color get releasePaperColor => penThemeById(releaseThemeId).paper;
  int get releaseParticleCount {
    switch (releaseInkWeight.value) {
      case 2:
        return 48;
      case 1:
        return 28;
      default:
        return 12;
    }
  }
  double get releaseFlashOpacity {
    switch (releaseInkWeight.value) {
      case 2:
        return 0.75;
      case 1:
        return 0.55;
      default:
        return 0.35;
    }
  }
  Future<void> playRelease({
    int inkWeight = 0,
    ImageProvider? burstImage,
    List<String> words = const [],
    String? burstLabel,
    int? quoteIntensity,
    String source = '',
  }) async {
    if (_releasing) return;
    _releasing = true;
    await _loadReleaseMode();
    releaseWords = words;
    releaseBurstLabel = burstLabel;
    releaseInkWeight.value = inkWeight;
    releaseBurstImage = burstImage;
    releasePhase.value = ReleasePhase.shredding;
    await HapticFeedback.heavyImpact();
    if (inkWeight >= 2) await HapticFeedback.mediumImpact();
    await Future.delayed(kShredFxDuration);
    if (isClosed) return;
    releaseQuote.value =
        await ReleaseQuotes.takeNext(intensity: quoteIntensity);
    if (source.isNotEmpty) {
      await Get.find<ConfettiDatabase>().markRelease(source);
    }
    if (isClosed) return;
    releasePhase.value = ReleasePhase.done;
  }
  Future<void> _loadReleaseMode() async {
    try {
      final pref = await Get.find<ConfettiDatabase>().getPreference();
      if (pref != null) {
        releaseMode.value = pref.shredMode;
      }
    } catch (_) {
      errorToast('Could not load shred mode.');
    }
  }
  void goHome() => Get.offAllNamed('/con_home');
  bool get showDrawAgain => false;
  String get againLabel => 'Draw another';
  bool get jarShare => false;
  void resetRelease() {
    _releasing = false;
    releaseBurstImage = null;
    releaseWords = const [];
    releaseBurstLabel = null;
    releaseInkWeight.value = 0;
    releaseQuote.value = '';
    releaseMode.value = ConfettiShredMode.physicalDegradation;
    releasePhase.value = ReleasePhase.idle;
  }
  void drawAgain() {}
}
class ConfettiReleaseHost extends StatelessWidget {
  final ConfettiReleaseMixin controller;
  final Widget child;
  const ConfettiReleaseHost({
    super.key,
    required this.controller,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeId = controller.releaseThemeId;
      final paperImage = controller.releasePaperImage;
      final paper = controller.releasePaperColor;
      switch (controller.releasePhase.value) {
        case ReleasePhase.shredding:
          final energy = controller.releaseBurstLabel != null &&
              controller.releaseBurstLabel!.isNotEmpty;
          return Scaffold(
            backgroundColor: energy ? const Color(0xFF2A221C) : paper,
            body: ConfettiShredOverlay(
              particleCount: controller.releaseParticleCount,
              flashOpacity: controller.releaseFlashOpacity,
              themeId: themeId,
              mode: controller.releaseMode.value,
              paperImage: paperImage,
              burstImage: controller.releaseBurstImage,
              words: controller.releaseWords,
              burstLabel: controller.releaseBurstLabel,
            ),
          );
        case ReleasePhase.done:
          return Scaffold(
            backgroundColor: paper,
            body: ConfettiDoneOverlay(
              quote: controller.releaseQuote.value,
              onOk: controller.goHome,
              onAgain:
                  controller.showDrawAgain ? controller.drawAgain : null,
              againLabel: controller.againLabel,
              energyLabel: controller.releaseBurstLabel,
              jarShare: controller.jarShare,
              themeId: themeId,
              paperImage: paperImage,
            ),
          );
        case ReleasePhase.idle:
          return child;
      }
    });
  }
}
