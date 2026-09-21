import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import '../../components/confetti_btn_stamp.dart';
import '../../components/confetti_paper_fill.dart';
import '../../components/confetti_release_flow.dart';
import '../confetti_write/confetti_write_logic.dart';
import 'confetti_countdown_decor.dart';
import 'confetti_countdown_logic.dart';
class ConfettiCountdownView extends GetView<ConfettiCountdownLogic> {
  const ConfettiCountdownView({super.key});
  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
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
          resizeToAvoidBottomInset: true,
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
                  _buildTimerSelector(),
                  Expanded(
                    child: RepaintBoundary(
                      key: controller.stageKey,
                      child: Column(
                        children: [
                          _buildCircularFrame(compact: keyboardOpen),
                          _buildNoteCard(
                            keyboardOpen: keyboardOpen,
                            destroyZoneHeight: 148.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (keyboardOpen)
                    _buildKeyboardShredBar()
                  else
                    _buildDestroyZone(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTimerSelector() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundMuted.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE9DFD6).withOpacity(0.8),
                ),
              ),
              child: Opacity(
                opacity: controller.isRunning.value ? 0.42 : 1.0,
                child: Row(
                  children: controller.minuteOptions.map((m) {
                    final on = controller.selectedMinutes.value == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectMinutes(m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            vertical: 6.h,
                            horizontal: 9.w,
                          ),
                          decoration: BoxDecoration(
                            color: on ? AppColors.destroy : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: on
                                ? [
                                    BoxShadow(
                                      color: AppColors.destroy.withOpacity(0.22),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            '$m min',
                            textAlign: TextAlign.center,
                            style: ConfettiFonts.outfit(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: on
                                  ? AppColors.onDestroy
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.onDiscardTap,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F2).withOpacity(0.72),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFF1C1917).withOpacity(0.08),
                ),
              ),
              child: Icon(
                Icons.close,
                size: 13.r,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCircularFrame({required bool compact}) {
    final height = compact ? 120.h : 258.h;
    final fontSize = compact ? 28.sp : 42.sp;
    return GestureDetector(
      onTap: controller.onTimerRingTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.fromLTRB(27.w, 4.h, 27.w, compact ? 8.h : 12.h),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200.r),
          border: Border.all(
            color: const Color(0xFFFFF8F2).withOpacity(0.42),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C1917).withOpacity(0.16),
              blurRadius: compact ? 18 : 36,
              offset: Offset(0, compact ? 8 : 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(200.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/illustrations/ill_countdown.png',
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0x00F3E6D4),
                        Color(0x331C1917),
                      ],
                      stops: [0.52, 1],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Obx(() => CustomPaint(
                  painter: CountdownFuseRingPainter(
                    progress: controller.fuseProgress,
                    urgent: controller.isUrgent,
                    started: controller.hasStarted.value,
                  ),
                )),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: controller.isTimerDimmed ? 0.28 : 1,
                      child: CountdownPulsingText(
                        text: controller.timeDisplay,
                        isUrgent: controller.isUrgent,
                        style: ConfettiFonts.fraunces(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: controller.isUrgent
                              ? AppColors.warning
                              : AppColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFF8F2).withOpacity(0.55),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    )),
                    if (!compact) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'SELF-DESTRUCTS',
                        style: ConfettiFonts.outfit(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFF8F2).withOpacity(0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNoteCard({
    required bool keyboardOpen,
    required double destroyZoneHeight,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: controller.onCardTap,
        onVerticalDragStart:
            keyboardOpen ? null : (_) => controller.onDragStart(),
        onVerticalDragUpdate: keyboardOpen
            ? null
            : (d) => controller.onDragUpdate(d.delta.dy, destroyZoneHeight),
        onVerticalDragEnd: keyboardOpen
            ? null
            : (_) => controller.onDragEnd(destroyZoneHeight),
        onVerticalDragCancel: keyboardOpen ? null : controller.onDragCancel,
        child: Obx(() {
          final dy = controller.dragOffset.value;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: (dy / 2200).clamp(0.0, 0.035),
              child: _buildNoteCardBody(),
            ),
          );
        }),
      ),
    );
  }
  Widget _buildNoteCardBody() {
    return Container(
      margin: EdgeInsets.fromLTRB(22.w, 0, 22.w, 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1917).withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF1C1917).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ConfettiPaperFill(
                asset: 'assets/illustrations/ill_write.png',
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 36.h,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x38FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Obx(() => controller.showEditor.value ||
                      controller.hasStarted.value
                  ? _buildTextField()
                  : _buildTapHint()),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTapHint() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Tap to start writing...',
              style: ConfettiFonts.fraunces(
                fontSize: 15.sp,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF2A261F).withOpacity(0.3),
              ),
            ),
          ),
        ),
        _buildStarterChips(),
      ],
    );
  }
  Widget _buildStarterChips() {
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ConfettiWriteLogic.starterChips.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final text = ConfettiWriteLogic.starterChips[i];
          return GestureDetector(
            onTap: () => controller.onStarterChipTap(text),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F2).withOpacity(0.82),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFF2A261F).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C1917).withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: ConfettiFonts.outfit(
                  fontSize: 11.sp,
                  color: const Color(0xFF2A261F).withOpacity(0.62),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildKeyboardShredBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 12.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x001E1B18), Color(0xE61E1B18), Color(0xFF1E1B18)],
        ),
      ),
      child: Obx(() => Opacity(
        opacity: controller.hasContent ? 1 : 0.38,
        child: ConfettiBtnStamp(
          text: 'Shred it now',
          fontSize: 15,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          onTap: controller.shredNow,
        ),
      )),
    );
  }
  Widget _buildTextField() {
    return TextField(
      controller: controller.textController,
      focusNode: controller.focusNode,
      maxLines: null,
      expands: true,
      autofocus: true,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      style: ConfettiFonts.fraunces(
        fontSize: 15.sp,
        height: 24 / 15,
        color: const Color(0xFF2A261F),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Write freely...',
        hintStyle: ConfettiFonts.fraunces(
          fontSize: 15.sp,
          color: const Color(0xFF2A261F).withOpacity(0.3),
          fontStyle: FontStyle.italic,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      cursorColor: AppColors.primary,
    );
  }
  Widget _buildDestroyZone() {
    return SizedBox(
      height: 148.h,
      child: Obx(() {
        final urgent = controller.isUrgent;
        final dragging = controller.isDragActive.value &&
            controller.dragOffset.value > 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.32, 0.72, 1.0],
              colors: dragging || urgent
                  ? const [
                      Color(0x001E1B18),
                      Color(0xB31E1B18),
                      Color(0xFF1A1410),
                      Color(0xFF1A1410),
                    ]
                  : const [
                      Color(0x001E1B18),
                      Color(0x8C1E1B18),
                      Color(0xFF1E1B18),
                      Color(0xFF1E1B18),
                    ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: urgent
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.destroyHighlight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: urgent
                          ? AppColors.primary
                          : AppColors.destroyHighlight,
                      shape: BoxShape.circle,
                      boxShadow: urgent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.55),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'SELF-DESTRUCT IMMINENT',
                    style: ConfettiFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: urgent
                          ? AppColors.primary
                          : AppColors.destroyHighlight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: controller.hasContent ? 1 : 0.38,
                        child: ConfettiBtnGhost(
                          text: controller.coachTitle,
                          onTap: controller.dragDown,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: Opacity(
                        opacity: controller.hasContent ? 1 : 0.38,
                        child: ConfettiBtnStamp(
                          text: 'Shred it now',
                          fontSize: 14,
                          padding: EdgeInsets.symmetric(
                            vertical: 11.h,
                            horizontal: 8.w,
                          ),
                          width: double.infinity,
                          onTap: controller.shredNow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 134.w,
                height: 5.h,
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F0E8).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
