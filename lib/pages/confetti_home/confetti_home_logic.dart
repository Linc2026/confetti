import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../db_confetti/data.dart';
import '../../db_confetti/db_confetti_entity.dart';
import '../../models/pen_theme.dart';
import '../../utils/index.dart';
class ConfettiHomeLogic extends GetxController {
  final selectedMode = 0.obs;
  final showPenSelector = false.obs;
  final countdownCompletions = 0.obs;
  final penSheetOffset = 0.0.obs;
  final lastThemeId = ''.obs;
  final lastToolId = ''.obs;
  final releasedToday = false.obs;
  final quietDay = false.obs;
  final modePreviewToken = 0.obs;
  static const _dismissThreshold = 80.0;
  ConfettiPreference? _pref;
  Timer? _previewTimer;
  bool _openTouched = false;
  @override
  void onReady() {
    super.onReady();
    reload();
  }
  @override
  void onClose() {
    _previewTimer?.cancel();
    super.onClose();
  }
  Future<void> reload() async {
    try {
      final db = Get.find<ConfettiDatabase>();
      _pref = await db.getPreference();
      if (_pref == null) return;
      selectedMode.value =
          _pref!.shredMode == ConfettiShredMode.everythingToZero ? 1 : 0;
      countdownCompletions.value = _pref!.countdownCompletions;
      lastThemeId.value = _effectiveLastTheme(_pref!);
      lastToolId.value = _pref!.lastToolId;
      _applyVisitFlags(_pref!);
      await _touchOpenDate(db, _pref!);
    } catch (_) {
      errorToast('Could not load preferences.');
    }
  }
  void _applyVisitFlags(ConfettiPreference pref) {
    final today = getDateString(DateTime.now());
    releasedToday.value = pref.lastReleaseDate == today;
    if (_openTouched) return;
    _openTouched = true;
    if (releasedToday.value || pref.lastOpenDate.isEmpty) {
      quietDay.value = false;
      return;
    }
    final days = _daysBetween(pref.lastOpenDate, today);
    quietDay.value = days != null && days >= 3;
  }
  Future<void> _touchOpenDate(
    ConfettiDatabase db,
    ConfettiPreference pref,
  ) async {
    final today = getDateString(DateTime.now());
    if (pref.lastOpenDate == today) return;
    final updated = pref.copyWith(lastOpenDate: today);
    await db.updatePreference(updated);
    _pref = updated;
  }
  int? _daysBetween(String from, String to) {
    final a = DateTime.tryParse(from);
    final b = DateTime.tryParse(to);
    if (a == null || b == null) return null;
    return b.difference(a).inDays;
  }
  String get ctaHint {
    if (releasedToday.value) return 'Released today · another is fine';
    if (quietDay.value) return 'Blank is also a release';
    if (lastThemeId.value.isNotEmpty) {
      return 'Hold for ${penThemeById(lastThemeId.value).name}';
    }
    return 'Tap to pick up the pen';
  }
  String _effectiveLastTheme(ConfettiPreference pref) {
    if (pref.lastThemeId.isEmpty) return '';
    final unused = pref.lastReleaseDate.isEmpty && pref.lastToolId.isEmpty;
    if (unused && pref.lastThemeId == 'crispyBlank') return '';
    return pref.lastThemeId;
  }
  String get recommendedTool {
    final hour = DateTime.now().hour;
    final last = lastToolId.value;
    final cycle = hour >= 22
        ? const ['countdown', 'doodle', 'wordJar', 'rageTap']
        : hour < 12
            ? const ['doodle', 'wordJar', 'rageTap']
            : hour < 18
                ? const ['wordJar', 'rageTap', 'doodle']
                : const ['rageTap', 'doodle', 'wordJar'];
    return cycle.firstWhere((id) => id != last, orElse: () => cycle.first);
  }
  void selectMode(int index) {
    if (selectedMode.value == index) return;
    selectedMode.value = index;
    _saveMode(index);
    if (index == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    modePreviewToken.value++;
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      modePreviewToken.value = 0;
    });
  }
  Future<void> _saveMode(int index) async {
    try {
      final db = Get.find<ConfettiDatabase>();
      final pref = _pref ?? await db.getPreference();
      if (pref == null) return;
      final updated = pref.copyWith(
        shredMode: index == 0
            ? ConfettiShredMode.physicalDegradation
            : ConfettiShredMode.everythingToZero,
      );
      await db.updatePreference(updated);
      _pref = updated;
    } catch (_) {
      errorToast('Could not save shred mode.');
    }
  }
  void openNote() {
    penSheetOffset.value = 0;
    showPenSelector.value = true;
  }
  void closePenSelector() {
    showPenSelector.value = false;
    penSheetOffset.value = 0;
  }
  void onPenSheetDragUpdate(double dy) {
    if (dy < 0 && penSheetOffset.value <= 0) return;
    penSheetOffset.value = (penSheetOffset.value + dy).clamp(0.0, 420.0);
  }
  void onPenSheetDragEnd() {
    if (penSheetOffset.value >= _dismissThreshold) {
      closePenSelector();
    } else {
      penSheetOffset.value = 0;
    }
  }
  String get _currentMode {
    return selectedMode.value == 0
        ? ConfettiShredMode.physicalDegradation
        : ConfettiShredMode.everythingToZero;
  }
  Future<void> _persistLastTheme(String themeId) async {
    try {
      final db = Get.find<ConfettiDatabase>();
      final pref = _pref ?? await db.getPreference();
      if (pref == null) return;
      final updated = pref.copyWith(lastThemeId: themeId);
      await db.updatePreference(updated);
      _pref = updated;
      lastThemeId.value = themeId;
    } catch (_) {
      errorToast('Could not save pen preference.');
    }
  }
  void onThemeTap(String themeId) {
    closePenSelector();
    _persistLastTheme(themeId);
    Get.toNamed(
      '/con_write',
      arguments: {'themeId': themeId, 'mode': _currentMode},
    );
  }
  void openLastNote() {
    if (lastThemeId.value.isEmpty) {
      openNote();
      return;
    }
    closePenSelector();
    Get.toNamed(
      '/con_write',
      arguments: {'themeId': lastThemeId.value, 'mode': _currentMode},
    );
  }
  void openLastMode() {
    switch (lastToolId.value) {
      case 'doodle':
        goDoodle();
      case 'wordJar':
        goWordJar();
      case 'rageTap':
        goRageTap();
      case 'countdown':
        goCountdown();
      default:
        openLastNote();
    }
  }
  void goAbout() => Get.toNamed('/con_about');
  void goDoodle() => Get.toNamed('/con_doodle');
  void goWordJar() => Get.toNamed('/con_word_jar');
  void goRageTap() => Get.toNamed('/con_rage_tap');
  void goCountdown() => Get.toNamed('/con_countdown');
}
