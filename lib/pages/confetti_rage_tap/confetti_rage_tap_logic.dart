import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import '../../components/confetti_discard_dialog.dart';
import '../../components/confetti_release_flow.dart';
import '../../utils/index.dart';
const int kRageRippleMs = 520;
class RippleData {
  final Offset position;
  final int startMs;
  const RippleData(this.position, this.startMs);
}
class CrackImpact {
  final Offset position;
  final int seed;
  final int startMs;
  const CrackImpact(this.position, this.seed, this.startMs);
}
class ConfettiRageTapLogic extends GetxController
    with WidgetsBindingObserver, ConfettiReleaseMixin {
  final hitCount = 0.obs;
  final ripples = <RippleData>[].obs;
  final heatLevel = 0.obs;
  final cooledDown = false.obs;
  final heatDots = <Offset>[].obs;
  final cracks = <CrackImpact>[].obs;
  final shakeGen = 0.obs;
  Timer? _longPressTimer;
  Timer? _pulseTimer;
  Timer? _heatTimer;
  bool _isLongPressing = false;
  Offset? _pressPosition;
  int? _lastHitAt;
  final _hitTimes = <int>[];
  final _rng = Random();
  int get inkWeight {
    final n = hitCount.value;
    if (n <= 0) return 0;
    if (n < 20) return 1;
    return 2;
  }
  String get coachLine {
    if (cooledDown.value) return 'Ease off — then release';
    final n = hitCount.value;
    if (n <= 0) return 'Tap to let it out';
    if (n < 20) return 'Keep going';
    return 'Release to shred';
  }
  @override
  bool get showDrawAgain => true;
  @override
  String get againLabel => 'Tap again';
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }
  void onTap(Offset position) => _registerHit(position);
  void _registerHit(Offset position) {
    if (releasePhase.value != ReleasePhase.idle) return;
    if (cooledDown.value) return;
    hitCount.value++;
    shakeGen.value++;
    _addRipple(position);
    _addHeatDot(position);
    _addCrack(position);
    _playHitHaptic();
    SystemSound.play(SystemSoundType.click);
    final now = DateTime.now().millisecondsSinceEpoch;
    _hitTimes.add(now);
    _updateHeat(now);
    _heatTimer ??= Timer.periodic(const Duration(milliseconds: 200), (_) {
      _updateHeat(DateTime.now().millisecondsSinceEpoch);
      if (_hitTimes.isEmpty) {
        _heatTimer?.cancel();
        _heatTimer = null;
      }
    });
  }
  void _playHitHaptic() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastHitAt;
    _lastHitAt = now;
    if (last == null) {
      HapticFeedback.mediumImpact();
      return;
    }
    final dt = now - last;
    if (dt < 120) {
      HapticFeedback.heavyImpact();
    } else if (dt < 280) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
  void _updateHeat(int now) {
    _hitTimes.removeWhere((t) => now - t > 2000);
    final n = _hitTimes.length;
    heatLevel.value = n <= 0 ? 0 : (n <= 5 ? 1 : 2);
  }
  void _addHeatDot(Offset position) {
    heatDots.add(position);
    if (heatDots.length > 40) heatDots.removeAt(0);
  }
  void _addCrack(Offset position) {
    cracks.add(CrackImpact(
      position,
      _rng.nextInt(1 << 31),
      DateTime.now().millisecondsSinceEpoch,
    ));
    if (cracks.length > 40) cracks.removeAt(0);
  }
  void _addRipple(Offset position) {
    final ripple = RippleData(
      position,
      DateTime.now().millisecondsSinceEpoch,
    );
    ripples.add(ripple);
    Future.delayed(const Duration(milliseconds: kRageRippleMs + 40), () {
      ripples.remove(ripple);
    });
  }
  Offset _jitter(Offset origin) {
    return Offset(
      origin.dx + (_rng.nextDouble() - 0.5) * 24,
      origin.dy + (_rng.nextDouble() - 0.5) * 24,
    );
  }
  Future<void> onLongPressStart(Offset position) async {
    if (releasePhase.value != ReleasePhase.idle) return;
    _isLongPressing = true;
    _pressPosition = position;
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!_isLongPressing) return;
      final origin = _pressPosition ?? position;
      _registerHit(_jitter(origin));
    });
    _longPressTimer = Timer(const Duration(seconds: 10), () {
      _stopLongPress(timedOut: true);
    });
    try {
      final available = await Vibration.hasVibrator();
      if (!_isLongPressing) return;
      if (available == true) {
        await Vibration.vibrate(duration: 10000, pattern: [0, 200, 100]);
      }
    } catch (_) {}
  }
  void onLongPressEnd() {
    _stopLongPress();
  }
  void _stopLongPress({bool timedOut = false}) {
    if (!_isLongPressing) return;
    _isLongPressing = false;
    _pressPosition = null;
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _longPressTimer?.cancel();
    _longPressTimer = null;
    if (timedOut) cooledDown.value = true;
    try {
      Vibration.cancel();
    } catch (_) {}
  }
  void _resetSession() {
    _stopLongPress();
    hitCount.value = 0;
    ripples.clear();
    heatDots.clear();
    cracks.clear();
    _hitTimes.clear();
    heatLevel.value = 0;
    shakeGen.value = 0;
    cooledDown.value = false;
    _lastHitAt = null;
    _heatTimer?.cancel();
    _heatTimer = null;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopLongPress();
    }
  }
  void onDiscardTap() {
    if (releasePhase.value == ReleasePhase.done) {
      goHome();
      return;
    }
    if (releasePhase.value == ReleasePhase.shredding) return;
    if (hitCount.value == 0) {
      Get.back();
      return;
    }
    ConfettiDiscardDialog.show(
      title: 'Stop and discard your rage?',
      content: 'Your hit count will be cleared.',
      onDiscard: Get.back,
    );
  }
  @override
  void drawAgain() {
    _resetSession();
    resetRelease();
  }
  void release() {
    if (hitCount.value <= 0) {
      errorToast('Tap first.');
      return;
    }
    if (releasePhase.value != ReleasePhase.idle) return;
    _stopLongPress();
    playRelease(
      inkWeight: inkWeight,
      burstLabel: '×${hitCount.value}',
      quoteIntensity: inkWeight,
      source: 'rageTap',
    );
  }
  @override
  void onClose() {
    _resetSession();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
