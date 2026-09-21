import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import '../../components/confetti_btn_stamp.dart';
import '../../components/confetti_destroy_horizon.dart';
import '../../components/confetti_release_flow.dart';
import 'confetti_doodle_decor.dart';
import 'confetti_doodle_logic.dart';
import 'confetti_doodle_painter.dart';
class ConfettiDoodleView extends GetView<ConfettiDoodleLogic> {
  const ConfettiDoodleView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.onDiscardTap();
      },
      child: ConfettiReleaseHost(
        controller: controller,
        child: Scaffold(
          backgroundColor: const Color(0xFFF3E6D4),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF7EDE0),
                  Color(0xFFF3E6D4),
                  Color(0xFFE8D8C0),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildToolbar(),
                  _buildBrushSelector(),
                  _buildBanner(),
                  Expanded(child: _buildCanvas()),
                  _buildDestroyZone(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(child: _buildColorDots()),
          SizedBox(width: 8.w),
          Obx(() {
            controller.strokes.length;
            controller.redoStack.length;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toolBtn(
                  onTap: controller.undo,
                  opacity: controller.strokes.isEmpty ? 0.35 : 1,
                  child: Icon(Icons.undo_rounded,
                      size: 15.r, color: AppColors.textSecondary),
                ),
                SizedBox(width: 6.w),
                _toolBtn(
                  onTap: controller.redo,
                  opacity: controller.redoStack.isEmpty ? 0.35 : 1,
                  child: Icon(Icons.redo_rounded,
                      size: 15.r, color: AppColors.textSecondary),
                ),
              ],
            );
          }),
          SizedBox(width: 6.w),
          Obx(() => _toolBtn(
            bgColor: controller.isEraser.value
                ? AppColors.primaryLight
                : AppColors.surface,
            onTap: controller.onEraserTap,
            child: Icon(
              Icons.auto_fix_normal_rounded,
              size: 15.r,
              color: controller.isEraser.value
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          )),
          SizedBox(width: 6.w),
          _toolBtn(
            bgColor: AppColors.textPrimary,
            onTap: controller.onDiscardTap,
            child: Icon(Icons.close, size: 13.r, color: const Color(0xFFF7F0E8)),
          ),
        ],
      ),
    );
  }
  Widget _buildColorDots() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colors = controller.colors;
        final gap = 5.w;
        final size = ((constraints.maxWidth - gap * (colors.length - 1)) /
                colors.length)
            .clamp(18.0, 26.r);
        return Row(
          children: [
            for (var i = 0; i < colors.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              _buildColorDot(colors[i], size),
            ],
          ],
        );
      },
    );
  }
  Widget _buildColorDot(Color color, double size) {
    return Obx(() {
      final isOn = !controller.isEraser.value &&
          controller.selectedColor.value == color;
      return GestureDetector(
        onTap: () => controller.selectColor(color),
        child: AnimatedScale(
          scale: isOn ? 1.08 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isOn ? AppColors.primary : Colors.white.withOpacity(0.55),
                width: isOn ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isOn ? 0.35 : 0.16),
                  blurRadius: isOn ? 6 : 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  Widget _toolBtn({
    required Widget child,
    required VoidCallback onTap,
    Color? bgColor,
    double opacity = 1,
  }) {
    final dark = bgColor == AppColors.textPrimary;
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: dark ? null : Border.all(color: AppColors.border.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C1917).withOpacity(dark ? 0.18 : 0.05),
                blurRadius: dark ? 6 : 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
  Widget _buildBrushSelector() {
    return Obx(() => Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withOpacity(0.65)),
      ),
      child: Row(
        children: List.generate(
          controller.brushes.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => controller.selectBrush(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 5.h),
                decoration: BoxDecoration(
                  color: controller.selectedBrushIndex.value == i
                      ? AppColors.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: controller.selectedBrushIndex.value == i
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1C1917).withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.brushes[i].name,
                      textAlign: TextAlign.center,
                      style: ConfettiFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: controller.selectedBrushIndex.value == i
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      width: 22.w + i * 8.w,
                      height: 1.6 + i * 1.2,
                      decoration: BoxDecoration(
                        color: controller.selectedBrushIndex.value == i
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
  Widget _buildBanner() {
    return Obx(() {
      controller.strokes.length;
      final show = !controller.hasStrokes;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, show ? 10.h : 0),
        height: show ? 118.h : 0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: show
              ? [
                  BoxShadow(
                    color: const Color(0xFF1C1917).withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/illustrations/ill_doodle.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.56),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33FFFFFF), Color(0x00000000), Color(0x33000000)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildCanvas() {
    return Obx(() {
      controller.strokes.length;
      final weight = controller.inkWeight;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8DC),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C1917).withOpacity(0.08 + weight * 0.03),
              blurRadius: 18 + weight * 4,
              offset: Offset(0, 7 + weight.toDouble()),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: GestureDetector(
            onPanDown: (d) => controller.startStroke(d.localPosition),
            onPanUpdate: (d) => controller.continueStroke(d.localPosition),
            onPanEnd: (_) => controller.endStroke(),
            onPanCancel: () => controller.endStroke(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  key: controller.canvasKey,
                  child: const ColoredBox(
                    color: Color(0xFFFFF8DC),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DoodlePaperGrain(),
                        _DoodleCanvasPaint(),
                      ],
                    ),
                  ),
                ),
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(child: IgnorePointer(child: DoodleCornerFold())),
                if (controller.eraserPos.value != null)
                  _buildEraserRing(controller.eraserPos.value!),
              ],
            ),
          ),
        ),
      );
    });
  }
  Widget _buildEraserRing(Offset pos) {
    final r = controller.eraserDiameter / 2;
    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      child: IgnorePointer(
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.08),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDestroyZone() {
    return ConfettiDestroyHorizon(
      height: 138.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 6.h),
            Obx(() {
              controller.strokes.length;
              return Column(
                children: [
                  Text(
                    controller.coachLine,
                    style: ConfettiFonts.outfit(
                      fontSize: 12.sp,
                      color: AppColors.onDestroyMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  DoodleInkTicks(inkWeight: controller.inkWeight),
                ],
              );
            }),
            SizedBox(height: 8.h),
            Obx(() {
              controller.strokes.length;
              return Opacity(
                opacity: controller.hasStrokes ? 1 : 0.38,
                child: ConfettiBtnStamp(
                  text: 'Shred it',
                  fontSize: 15,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  width: double.infinity,
                  onTap: controller.shred,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
class _DoodleCanvasPaint extends GetView<ConfettiDoodleLogic> {
  const _DoodleCanvasPaint();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.strokes.length;
      final empty = controller.strokes.isEmpty &&
          controller.currentStrokeData == null;
      return CustomPaint(
        painter: DoodlePainter(
          strokes: controller.strokes.toList(),
          currentStroke: controller.currentStrokeData,
        ),
        size: Size.infinite,
        child: empty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Draw it out...',
                      style: ConfettiFonts.fraunces(
                        fontSize: 16.sp,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF2A261F).withOpacity(0.22),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 48.w,
                      height: 1,
                      color: const Color(0xFF2A261F).withOpacity(0.1),
                    ),
                  ],
                ),
              )
            : null,
      );
    });
  }
}
