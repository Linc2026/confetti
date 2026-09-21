import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../components/confetti_discard_dialog.dart';
import '../../components/confetti_release_flow.dart';
import '../../utils/index.dart';
class DoodleBrush {
  final String name;
  final double strokeWidth;
  const DoodleBrush(this.name, this.strokeWidth);
}
class DoodlePoint {
  final Offset offset;
  final double width;
  const DoodlePoint(this.offset, this.width);
}
class DoodleStroke {
  final List<DoodlePoint> points;
  final Color color;
  final bool isEraser;
  const DoodleStroke({
    required this.points,
    required this.color,
    this.isEraser = false,
  });
  DoodleStroke copyWithPoint(DoodlePoint point) {
    return DoodleStroke(
      points: [...points, point],
      color: color,
      isEraser: isEraser,
    );
  }
}
class ConfettiDoodleLogic extends GetxController with ConfettiReleaseMixin {
  final canvasKey = GlobalKey();
  final selectedColor = const Color(0xFF1C1917).obs;
  final selectedBrushIndex = 0.obs;
  final isEraser = false.obs;
  final strokes = <DoodleStroke>[].obs;
  final redoStack = <DoodleStroke>[].obs;
  final eraserPos = Rxn<Offset>();
  DoodleStroke? _currentStroke;
  bool _shredding = false;
  final colors = const [
    Color(0xFF1C1917),
    Color(0xFF8B1E1E),
    Color(0xFFE07A2F),
    Color(0xFF1E3A5F),
    Color(0xFF2D5A3D),
    Color(0xFF5A3A6B),
    Color(0xFF7A716A),
    Color(0xFF6B4423),
  ];
  final brushes = const [
    DoodleBrush('Fine', 2.0),
    DoodleBrush('Medium', 4.0),
    DoodleBrush('Thick', 7.0),
  ];
  double get currentStrokeWidth => brushes[selectedBrushIndex.value].strokeWidth;
  double get eraserDiameter => currentStrokeWidth * 3;
  int get inkWeight {
    var count = strokes.length;
    var points = 0;
    for (final s in strokes) {
      points += s.points.length;
    }
    if (_currentStroke != null) {
      count += 1;
      points += _currentStroke!.points.length;
    }
    if (count <= 0) return 0;
    final short = count <= 3 && points <= 80;
    if (short && _peakGap <= 28) return 1;
    return 2;
  }
  double get _peakGap {
    var peak = 0.0;
    void scan(DoodleStroke s) {
      for (var i = 1; i < s.points.length; i++) {
        final g = (s.points[i].offset - s.points[i - 1].offset).distance;
        if (g > peak) peak = g;
      }
    }
    for (final s in strokes) {
      scan(s);
    }
    if (_currentStroke != null) scan(_currentStroke!);
    return peak;
  }
  String get coachLine {
    switch (inkWeight) {
      case 2:
        return 'Release to shred';
      case 1:
        return 'Keep going';
      default:
        return 'Tear it to pieces';
    }
  }
  @override
  bool get showDrawAgain => true;
  void selectColor(Color color) {
    selectedColor.value = color;
    isEraser.value = false;
    eraserPos.value = null;
  }
  void selectBrush(int index) => selectedBrushIndex.value = index;
  void onEraserTap() {
    isEraser.value = !isEraser.value;
    if (!isEraser.value) eraserPos.value = null;
  }
  void startStroke(Offset point) {
    if (_shredding) return;
    final base = isEraser.value ? eraserDiameter : currentStrokeWidth;
    _currentStroke = DoodleStroke(
      points: [DoodlePoint(point, base)],
      color: selectedColor.value,
      isEraser: isEraser.value,
    );
    if (isEraser.value) eraserPos.value = point;
    strokes.refresh();
  }
  void continueStroke(Offset point) {
    if (_currentStroke == null) return;
    final last = _currentStroke!.points.last.offset;
    final gap = (point - last).distance;
    final base = _currentStroke!.isEraser ? eraserDiameter : currentStrokeWidth;
    final width = _currentStroke!.isEraser
        ? base
        : base * (1 + ((gap - 2) / 28).clamp(0.0, 1.0) * 1.2);
    _currentStroke = _currentStroke!.copyWithPoint(DoodlePoint(point, width));
    if (isEraser.value) eraserPos.value = point;
    strokes.refresh();
  }
  void endStroke() {
    if (_currentStroke != null && _currentStroke!.points.isNotEmpty) {
      strokes.add(_currentStroke!);
      redoStack.clear();
    }
    _currentStroke = null;
    eraserPos.value = null;
  }
  DoodleStroke? get currentStrokeData => _currentStroke;
  bool get hasStrokes => strokes.isNotEmpty || _currentStroke != null;
  void undo() {
    if (strokes.isEmpty) return;
    redoStack.add(strokes.removeLast());
  }
  void redo() {
    if (redoStack.isEmpty) return;
    strokes.add(redoStack.removeLast());
  }
  void clearCanvas() {
    strokes.clear();
    redoStack.clear();
    _currentStroke = null;
    eraserPos.value = null;
  }
  void onDiscardTap() {
    if (releasePhase.value == ReleasePhase.done) {
      goHome();
      return;
    }
    if (releasePhase.value == ReleasePhase.shredding) return;
    if (!hasStrokes) {
      Get.back();
      return;
    }
    ConfettiDiscardDialog.show(
      title: 'Discard this doodle?',
      content: 'Your drawing will be lost.',
      onDiscard: Get.back,
    );
  }
  @override
  void drawAgain() {
    _shredding = false;
    clearCanvas();
    resetRelease();
  }
  Future<void> shred() async {
    if (!hasStrokes) {
      errorToast('Draw something first.');
      return;
    }
    if (_shredding || releasePhase.value != ReleasePhase.idle) return;
    _shredding = true;
    endStroke();
    final weight = inkWeight;
    final snapshot = await _captureCanvas();
    if (isClosed) return;
    clearCanvas();
    await playRelease(
      inkWeight: weight,
      burstImage: snapshot,
      source: 'doodle',
    );
  }
  Future<ImageProvider?> _captureCanvas() async {
    try {
      final ctx = canvasKey.currentContext;
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
}
