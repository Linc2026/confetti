import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import '../../components/confetti_btn_stamp.dart';
import '../../components/confetti_paper_fill.dart';
import '../../components/confetti_release_flow.dart';
import 'confetti_write_logic.dart';
class ConfettiWriteView extends GetView<ConfettiWriteLogic> {
  const ConfettiWriteView({super.key});
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
        child: _buildWritingScaffold(context),
      ),
    );
  }
  Widget _buildWritingScaffold(BuildContext context) {
    final theme = controller.currentTheme;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final destroyZoneHeight = 164.h;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: controller.dismissKeyboard,
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 8.h),
            _buildModeRow(),
            SizedBox(height: 6.h),
            _buildDraggableCard(
              theme,
              keyboardOpen: keyboardOpen,
              destroyZoneHeight: destroyZoneHeight,
            ),
            if (keyboardOpen)
              Obx(() => _buildKeyboardShredBar())
            else
              Obx(() => _buildDestroyZone(destroyZoneHeight)),
          ],
        ),
      ),
    );
  }
  Widget _buildModeRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 7.h, 12.w, 7.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F2).withOpacity(0.82),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE9DFD6).withOpacity(0.75)),
        ),
        child: Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.45),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                controller.currentModeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ConfettiFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                '· ${controller.currentModeSub}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ConfettiFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDraggableCard(
    theme, {
    required bool keyboardOpen,
    required double destroyZoneHeight,
  }) {
    return Expanded(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final cardHeight = constraints.maxHeight;
          return GestureDetector(
            onTap: controller.onCardTap,
            onPanStart: keyboardOpen ? null : (_) => controller.onDragStart(),
            onPanUpdate: keyboardOpen
                ? null
                : (d) => controller.onDragUpdate(d.delta.dy, destroyZoneHeight),
            onPanEnd: keyboardOpen
                ? null
                : (_) => controller.onDragEnd(destroyZoneHeight),
            onPanCancel: keyboardOpen ? null : controller.onDragCancel,
            child: Obx(() {
              final dy = controller.dragOffset.value;
              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: (dy / 2200).clamp(0.0, 0.035),
                  child: _buildNoteCard(theme, cardHeight),
                ),
              );
            }),
          );
        },
      ),
    );
  }
  List<BoxShadow> _cardShadows(int weight) {
    final depth = weight == 2 ? 0.32 : (weight == 1 ? 0.24 : 0.18);
    final blur = weight == 2 ? 56.0 : (weight == 1 ? 48.0 : 40.0);
    final y = weight == 2 ? 26.0 : (weight == 1 ? 22.0 : 18.0);
    return [
      BoxShadow(
        color: const Color(0xFF1C1917).withOpacity(depth),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
      BoxShadow(
        color: const Color(0xFF1C1917).withOpacity(weight == 2 ? 0.14 : 0.08),
        blurRadius: weight == 2 ? 14 : 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  Widget _buildNoteCard(theme, double cardHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: _cardShadows(controller.inkWeight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: ConfettiPaperFill(asset: theme.paperImage),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 36.h,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(26.w, 16.h, 22.w, 22.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.h, right: 8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.todayLabel,
                                  style: ConfettiFonts.outfit(
                                    fontSize: 11.sp,
                                    color: theme.ink.withOpacity(0.38),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  height: 1,
                                  color: theme.ink.withOpacity(0.10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.onDiscardTap,
                          child: Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: BoxDecoration(
                              color: theme.ink.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: theme.ink.withOpacity(0.06),
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 13.r,
                              color: theme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: controller.isFadingOut.value ? 0 : 1,
                        duration: const Duration(milliseconds: 350),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.charCount.value == 0)
                              _buildStarterChips(theme)
                            else
                              SizedBox(height: 14.h),
                            Expanded(child: _buildLinedField(theme)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLinedField(theme) {
    final spacing = 28.h;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _RuledLinesPainter(
              color: theme.ink.withOpacity(0.10),
              spacing: spacing,
            ),
          ),
        ),
        TextField(
          controller: controller.textController,
          focusNode: controller.focusNode,
          maxLines: null,
          expands: true,
          autofocus: false,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.top,
          style: ConfettiFonts.fraunces(
            fontSize: 17.sp,
            height: spacing / 17.sp,
            color: theme.ink,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Write what\'s weighing on you...',
            hintStyle: ConfettiFonts.fraunces(
              fontSize: 17.sp,
              height: spacing / 17.sp,
              color: theme.ink.withOpacity(0.28),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 4.h),
          ),
          cursorColor: AppColors.primary,
          cursorWidth: 2,
        ),
      ],
    );
  }
  Widget _buildStarterChips(theme) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 10.h),
      child: SizedBox(
        height: 32.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
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
                  color: const Color(0xFFFFF8F2).withOpacity(0.72),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: theme.ink.withOpacity(0.12)),
                ),
                child: Text(
                  text,
                  style: ConfettiFonts.outfit(
                    fontSize: 11.sp,
                    color: theme.ink.withOpacity(0.62),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
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
      child: Opacity(
        opacity: controller.hasContent ? 1 : 0.38,
        child: ConfettiBtnStamp(
          text: 'Shred it',
          fontSize: 15,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          onTap: controller.shred,
        ),
      ),
    );
  }
  Widget _buildDestroyZone(double destroyZoneHeight) {
    final isActive =
        controller.isDragActive.value && controller.dragOffset.value > 0;
    final heavy = controller.inkWeight == 2;
    final ready = controller.coachTitle == 'Release to shred';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: destroyZoneHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.32, 0.72, 1.0],
          colors: isActive
              ? [
                  const Color(0x001E1B18),
                  AppColors.primary.withOpacity(heavy ? 0.45 : 0.28),
                  const Color(0xE61E1B18),
                  const Color(0xFF1E1B18),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isActive ? 56.w : 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.destroyHighlight,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.55),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: 8.h),
          Icon(
            ready
                ? Icons.keyboard_double_arrow_down_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: isActive ? AppColors.onDestroy : AppColors.onDestroyMuted,
            size: 18.r,
          ),
          Text(
            controller.coachTitle,
            textAlign: TextAlign.center,
            style: ConfettiFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onDestroy,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            controller.coachSub,
            textAlign: TextAlign.center,
            style: ConfettiFonts.outfit(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.onDestroyMuted,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Opacity(
              opacity: controller.hasContent ? 1 : 0.38,
              child: ConfettiBtnStamp(
                text: 'Shred it',
                fontSize: 15,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                onTap: controller.shred,
              ),
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
  }
}
class _RuledLinesPainter extends CustomPainter {
  final Color color;
  final double spacing;
  _RuledLinesPainter({required this.color, required this.spacing});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = spacing - 2; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _RuledLinesPainter old) =>
      old.color != color || old.spacing != spacing;
}
