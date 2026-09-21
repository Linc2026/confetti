import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'confetti_release_flow.dart';
mixin ConfettiDragMixin on GetxController, GetSingleTickerProviderStateMixin {
  final dragOffset = 0.0.obs;
  final isDragActive = false.obs;
  late final AnimationController dragSpringController;
  void Function()? _springTick;
  int _bounceGen = 0;
  double destroyZoneHeight = 164;
  int _lastCoachBucket = 0;
  double _dragSlop = 0;
  bool get dragRequiresSlop => false;
  bool get canStartDrag => true;
  void onDragCommit();
  double get coachProgress {
    final threshold = destroyZoneHeight * 0.5;
    if (threshold <= 0) return 0;
    return dragOffset.value / threshold;
  }
  void initDragSpring() {
    dragSpringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
  }
  void onDragStart() {
    if (!canStartDrag) return;
    if (this is ConfettiReleaseMixin) {
      final release = this as ConfettiReleaseMixin;
      if (release.releasePhase.value != ReleasePhase.idle) return;
    }
    _dragSlop = 0;
    _bounceGen++;
    stopDragSpring();
    _lastCoachBucket = 0;
    if (!dragRequiresSlop) {
      isDragActive.value = true;
    }
  }
  void onDragUpdate(double dy, double maxOffset) {
    if (!canStartDrag) return;
    if (this is ConfettiReleaseMixin) {
      final release = this as ConfettiReleaseMixin;
      if (release.releasePhase.value != ReleasePhase.idle) return;
    }
    _dragSlop += dy;
    if (!isDragActive.value) {
      if (dragRequiresSlop && _dragSlop < 10) return;
      isDragActive.value = true;
    }
    destroyZoneHeight = maxOffset;
    final cap = maxOffset <= 0 ? 1.0 : maxOffset;
    dragOffset.value = (dragOffset.value + dy).clamp(0.0, cap);
    _tickCoachHaptic();
  }
  void onDragEnd(double zoneHeight) {
    if (!isDragActive.value) return;
    destroyZoneHeight = zoneHeight;
    if (dragOffset.value >= zoneHeight * 0.5) {
      onDragCommit();
    } else {
      bounceDragBack();
    }
  }
  void onDragCancel() {
    if (!isDragActive.value) return;
    bounceDragBack();
  }
  void _tickCoachHaptic() {
    final p = coachProgress;
    var bucket = 0;
    if (p >= 1.0) {
      bucket = 2;
    } else if (p >= 0.4) {
      bucket = 1;
    }
    if (bucket > _lastCoachBucket) {
      if (bucket == 1) HapticFeedback.selectionClick();
      if (bucket == 2) HapticFeedback.mediumImpact();
    }
    _lastCoachBucket = bucket;
  }
  void bounceDragBack() {
    stopDragSpring();
    final start = dragOffset.value;
    if (start <= 0) {
      dragOffset.value = 0;
      isDragActive.value = false;
      return;
    }
    final gen = ++_bounceGen;
    final anim = Tween<double>(begin: start, end: 0).animate(
      CurvedAnimation(parent: dragSpringController, curve: Curves.easeOutBack),
    );
    _springTick = () {
      final v = anim.value;
      dragOffset.value = v < 0 ? 0.0 : v;
    };
    dragSpringController
      ..reset()
      ..addListener(_springTick!);
    dragSpringController.forward().whenComplete(() {
      if (isClosed || gen != _bounceGen) return;
      stopDragSpring();
      dragOffset.value = 0;
      isDragActive.value = false;
    });
  }
  void stopDragSpring() {
    if (_springTick != null) {
      dragSpringController.removeListener(_springTick!);
      _springTick = null;
    }
    if (dragSpringController.isAnimating) {
      dragSpringController.stop();
    }
  }
  void resetDrag() {
    _bounceGen++;
    stopDragSpring();
    isDragActive.value = false;
    dragOffset.value = 0;
    _dragSlop = 0;
    _lastCoachBucket = 0;
  }
  void disposeDragSpring() {
    _bounceGen++;
    stopDragSpring();
    dragSpringController.dispose();
  }
}
