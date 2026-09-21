import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/confetti_discard_dialog.dart';
import '../../components/confetti_drag_mixin.dart';
import '../../components/confetti_release_flow.dart';
import '../../db_confetti/db_confetti_entity.dart';
import '../../models/pen_theme.dart';
import '../../utils/index.dart';
class ConfettiWriteLogic extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        ConfettiReleaseMixin,
        ConfettiDragMixin {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final charCount = 0.obs;
  final isFadingOut = false.obs;
  static const starterChips = [
    'I can\'t stop thinking about…',
    'I\'m angry that…',
    'I feel so overwhelmed…',
    'I wish I could tell them…',
    'I\'m tired of…',
    'Today I need to let go of…',
  ];
  bool get hasContent => charCount.value > 0;
  int get inkWeight {
    final n = charCount.value;
    if (n <= 0) return 0;
    if (n <= 80) return 1;
    return 2;
  }
  late final String _themeId;
  late final String _mode;
  PenTheme get currentTheme => penThemeById(_themeId);
  @override
  String get releaseThemeId => _themeId;
  @override
  String get releasePaperImage => currentTheme.paperImage;
  String get currentModeLabel =>
      _mode == ConfettiShredMode.everythingToZero
          ? 'Everything Returns to Zero'
          : 'Physical Degradation';
  String get currentModeSub =>
      _mode == ConfettiShredMode.everythingToZero
          ? 'Dissolves into nothing'
          : 'Tears into pieces';
  String get todayLabel {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = now.hour;
    final ampm = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final min = now.minute.toString().padLeft(2, '0');
    return '${months[now.month - 1]} ${now.day}, ${now.year} · $hour:$min $ampm';
  }
  @override
  bool get canStartDrag =>
      hasContent && releasePhase.value == ReleasePhase.idle;
  String get coachTitle {
    if (!hasContent) return 'Write first';
    if (!isDragActive.value || dragOffset.value <= 0) return 'Drag Down';
    final p = coachProgress;
    if (p >= 1.0) return 'Release to shred';
    if (p >= 0.4) return 'Keep going';
    return 'Drag Down';
  }
  String get coachSub {
    if (!hasContent) return 'A note needs words to let go';
    if (!isDragActive.value || dragOffset.value <= 0) {
      return 'Release emotions, move forward';
    }
    final p = coachProgress;
    if (p >= 1.0) return 'Let go';
    if (p >= 0.4) return 'Almost there';
    return 'Release emotions, move forward';
  }
  @override
  bool get showDrawAgain => true;
  @override
  String get againLabel => 'Write another';
  @override
  void onInit() {
    super.onInit();
    initDragSpring();
    textController.addListener(_onTextChanged);
    final args = Get.arguments;
    if (args is Map) {
      _themeId = (args['themeId'] as String?) ?? 'crispyBlank';
      _mode = (args['mode'] as String?) ?? ConfettiShredMode.physicalDegradation;
    } else {
      _themeId = 'crispyBlank';
      _mode = ConfettiShredMode.physicalDegradation;
    }
  }
  void _onTextChanged() {
    final raw = textController.text;
    charCount.value = raw.trim().isEmpty ? 0 : raw.length;
  }
  void onStarterChipTap(String text) {
    textController
      ..text = '$text '
      ..selection = TextSelection.collapsed(offset: textController.text.length);
    focusNode.requestFocus();
  }
  void onDiscardTap() {
    if (releasePhase.value == ReleasePhase.done) {
      goHome();
      return;
    }
    if (releasePhase.value == ReleasePhase.shredding) return;
    if (textController.text.trim().isEmpty) {
      Get.back();
      return;
    }
    ConfettiDiscardDialog.show(
      title: 'Discard this note?',
      content: 'Your writing will be lost.',
      onDiscard: Get.back,
    );
  }
  void onCardTap() {
    focusNode.requestFocus();
  }
  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  @override
  void onDragCommit() => shred();
  Future<void> shred() async {
    if (!hasContent) {
      errorToast('Write something first.');
      return;
    }
    if (releasePhase.value != ReleasePhase.idle) return;
    dismissKeyboard();
    isFadingOut.value = true;
    await Future.delayed(const Duration(milliseconds: 350));
    if (isClosed) return;
    await playRelease(
      inkWeight: inkWeight,
      quoteIntensity: inkWeight,
      source: 'write',
    );
  }
  @override
  void drawAgain() {
    textController.clear();
    charCount.value = 0;
    isFadingOut.value = false;
    resetDrag();
    resetRelease();
  }
  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    disposeDragSpring();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
