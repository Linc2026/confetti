import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../components/confetti_discard_dialog.dart';
import '../../components/confetti_drag_mixin.dart';
import '../../components/confetti_release_flow.dart';
import '../../db_confetti/data.dart';
import '../../utils/confetti_timezone.dart';
import '../../utils/index.dart';
class ConfettiCountdownLogic extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        ConfettiReleaseMixin,
        ConfettiDragMixin {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final stageKey = GlobalKey();
  final charCount = 0.obs;
  final showEditor = false.obs;
  bool get hasContent => charCount.value > 0;
  int get inkWeight {
    final n = charCount.value;
    if (n <= 0) return 0;
    if (n <= 80) return 1;
    return 2;
  }
  final selectedMinutes = 3.obs;
  final remainingSeconds = (3 * 60).obs;
  final isRunning = false.obs;
  final hasStarted = false.obs;
  Timer? _timer;
  Timer? _peekTimer;
  DateTime? _startTimestamp;
  int _totalSeconds = 3 * 60;
  final timerPeeked = false.obs;
  final minuteOptions = const [1, 3, 5, 10];
  static const int _notifId = 9001;
  final _notifPlugin = FlutterLocalNotificationsPlugin();
  bool _notifInitialized = false;
  String get timeDisplay {
    final m = remainingSeconds.value ~/ 60;
    final s = remainingSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  bool get isUrgent => remainingSeconds.value <= 10;
  bool get isTimerDimmed =>
      hasStarted.value && remainingSeconds.value > 30 && !timerPeeked.value;
  double get fuseProgress {
    if (!hasStarted.value || _totalSeconds <= 0) return 1;
    return (remainingSeconds.value / _totalSeconds).clamp(0.0, 1.0);
  }
  @override
  bool get dragRequiresSlop => true;
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
  @override
  bool get showDrawAgain => true;
  @override
  String get againLabel => 'Light another fuse';
  @override
  void onInit() {
    super.onInit();
    initDragSpring();
    textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
    _loadLastMinutes();
  }
  void _onTextChanged() {
    final raw = textController.text;
    charCount.value = raw.trim().isEmpty ? 0 : raw.length;
  }
  Future<void> _initNotifications() async {
    const initSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifPlugin.initialize(initSettings);
    _notifInitialized = true;
  }
  Future<void> _requestNotifPermission() async {
    try {
      final ios = _notifPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, sound: true, badge: false);
      final android = _notifPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } catch (_) {}
  }
  void selectMinutes(int minutes) {
    if (isRunning.value) return;
    _applyMinutes(minutes);
    _persistLastMinutes(minutes);
  }
  void _applyMinutes(int minutes) {
    selectedMinutes.value = minutes;
    _totalSeconds = minutes * 60;
    remainingSeconds.value = _totalSeconds;
  }
  Future<void> _loadLastMinutes() async {
    try {
      final db = Get.find<ConfettiDatabase>();
      final pref = await db.getPreference();
      if (pref == null || hasStarted.value) return;
      final m = minuteOptions.contains(pref.lastCountdownMinutes)
          ? pref.lastCountdownMinutes
          : 3;
      _applyMinutes(m);
    } catch (_) {}
  }
  Future<void> _persistLastMinutes(int minutes) async {
    try {
      final db = Get.find<ConfettiDatabase>();
      final pref = await db.getPreference();
      if (pref == null) return;
      await db.updatePreference(pref.copyWith(lastCountdownMinutes: minutes));
    } catch (_) {
      errorToast('Could not save timer preference.');
    }
  }
  Future<void> _bumpCompletions() async {
    try {
      final db = Get.find<ConfettiDatabase>();
      final pref = await db.getPreference();
      if (pref == null) return;
      await db.updatePreference(
        pref.copyWith(countdownCompletions: pref.countdownCompletions + 1),
      );
    } catch (_) {}
  }
  void peekTimer() {
    if (!isTimerDimmed && !timerPeeked.value) return;
    timerPeeked.value = true;
    _peekTimer?.cancel();
    _peekTimer = Timer(const Duration(seconds: 2), () {
      if (!isClosed) timerPeeked.value = false;
    });
  }
  void onTimerRingTap() {
    if (hasStarted.value) {
      peekTimer();
      return;
    }
    startTimer();
  }
  void onCardTap() {
    showEditor.value = true;
    focusNode.requestFocus();
  }
  void onStarterChipTap(String text) {
    textController
      ..text = '$text '
      ..selection = TextSelection.collapsed(offset: textController.text.length);
    showEditor.value = true;
    focusNode.requestFocus();
  }
  void startTimer() {
    if (isRunning.value) return;
    hasStarted.value = true;
    isRunning.value = true;
    _startTimestamp = DateTime.now();
    _totalSeconds = remainingSeconds.value;
    _requestNotifPermission();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        _tickFuseHaptic();
      } else {
        _timer?.cancel();
        isRunning.value = false;
        _cancelNotification();
        _onTimerZero();
      }
    });
  }
  void _tickFuseHaptic() {
    final left = remainingSeconds.value;
    if (left == 30) {
      HapticFeedback.selectionClick();
    } else if (left == 10 || left == 5) {
      HapticFeedback.mediumImpact();
    }
  }
  void _onTimerZero() {
    if (hasContent) {
      shredNow();
      return;
    }
    errorToast('Write something first.');
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ticking =
        isRunning.value && releasePhase.value == ReleasePhase.idle;
    if (state == AppLifecycleState.paused && ticking) {
      _scheduleNotification();
    } else if (state == AppLifecycleState.resumed && ticking) {
      _cancelNotification();
      _calibrateTimer();
    }
  }
  void _calibrateTimer() {
    if (_startTimestamp == null) return;
    final elapsed = DateTime.now().difference(_startTimestamp!).inSeconds;
    final newRemaining = _totalSeconds - elapsed;
    if (newRemaining <= 0) {
      _timer?.cancel();
      isRunning.value = false;
      remainingSeconds.value = 0;
      _onTimerZero();
    } else {
      remainingSeconds.value = newRemaining;
    }
  }
  Future<void> _scheduleNotification() async {
    if (!_notifInitialized || remainingSeconds.value <= 0) return;
    if (!localTimezoneReady) return;
    try {
      const details = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'confetti_countdown',
          'Countdown',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      final fireAt = tz.TZDateTime.now(tz.local)
          .add(Duration(seconds: remainingSeconds.value));
      try {
        await _notifPlugin.zonedSchedule(
          _notifId,
          'Confetti',
          'Time\'s up.',
          fireAt,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        await _notifPlugin.zonedSchedule(
          _notifId,
          'Confetti',
          'Time\'s up.',
          fireAt,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (_) {}
  }
  Future<void> _cancelNotification() async {
    try {
      await _notifPlugin.cancel(_notifId);
    } catch (_) {}
  }
  void onDiscardTap() {
    if (releasePhase.value == ReleasePhase.done) {
      goHome();
      return;
    }
    if (releasePhase.value == ReleasePhase.shredding) return;
    if (!hasStarted.value && textController.text.trim().isEmpty) {
      Get.back();
      return;
    }
    final started = hasStarted.value;
    ConfettiDiscardDialog.show(
      title: started
          ? 'Discard and stop the timer?'
          : 'Discard this note?',
      content: started
          ? 'The countdown will stop and your note will be lost.'
          : 'Your writing will be lost.',
      onDiscard: () {
        _timer?.cancel();
        isRunning.value = false;
        _cancelNotification();
        Get.back();
      },
    );
  }
  @override
  void onDragCommit() => shredNow();
  Future<void> shredNow() async {
    if (!hasContent) {
      errorToast('Write something first.');
      return;
    }
    if (releasePhase.value != ReleasePhase.idle) return;
    _timer?.cancel();
    isRunning.value = false;
    _cancelNotification();
    final weight = inkWeight;
    final snapshot = await _captureStage();
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isDialogOpen == true) Get.back();
    await _bumpCompletions();
    if (!isClosed) {
      playRelease(
        inkWeight: weight,
        burstImage: snapshot,
        quoteIntensity: weight,
        source: 'countdown',
      );
    }
  }
  Future<ImageProvider?> _captureStage() async {
    try {
      final ctx = stageKey.currentContext;
      if (ctx == null) return null;
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return null;
      return MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }
  void dragDown() => shredNow();
  @override
  void drawAgain() {
    _timer?.cancel();
    _cancelNotification();
    resetDrag();
    textController.clear();
    charCount.value = 0;
    showEditor.value = false;
    hasStarted.value = false;
    isRunning.value = false;
    _startTimestamp = null;
    timerPeeked.value = false;
    _peekTimer?.cancel();
    _applyMinutes(selectedMinutes.value);
    resetRelease();
  }
  @override
  void onClose() {
    disposeDragSpring();
    _peekTimer?.cancel();
    _timer?.cancel();
    _cancelNotification();
    textController.removeListener(_onTextChanged);
    textController.dispose();
    focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
