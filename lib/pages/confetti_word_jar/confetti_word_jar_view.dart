import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import '../../components/confetti_btn_stamp.dart';
import '../../components/confetti_release_flow.dart';
import 'confetti_word_jar_logic.dart';
import 'confetti_word_jar_tray.dart';
class ConfettiWordJarView extends GetView<ConfettiWordJarLogic> {
  const ConfettiWordJarView({super.key});
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
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildHero(),
                  _buildTitle(),
                  Expanded(child: _buildWordList()),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomCta(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHero() {
    return Stack(
      children: [
        GestureDetector(
          onTap: controller.grabFromJar,
          behavior: HitTestBehavior.opaque,
          child: Image.asset(
            'assets/illustrations/ill_word_jar.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
          top: MediaQuery.of(Get.context!).padding.top + 8.h,
          right: 16.w,
          child: GestureDetector(
            onTap: controller.onDiscardTap,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.86),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.close, size: 13.r, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 6.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Pick your words',
          style: ConfettiFonts.fraunces(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
  Widget _buildWordList() {
    return Obx(() {
      final bottom = controller.totalSelected > 0 ? 188.h : 140.h;
      return ListView(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, bottom),
        children: [
          ...ConfettiWordJarLogic.categories.map((cat) => _buildCategory(cat)),
          _buildCustomCategory(),
        ],
      );
    });
  }
  Widget _buildCategory(WordCategory cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryLabel(cat.name, isCustom: false),
        SizedBox(height: 2.h),
        _buildChipRow(cat.name, cat.words),
      ],
    );
  }
  Widget _buildCustomCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryLabel('Custom', isCustom: true),
        SizedBox(height: 2.h),
        Obx(() => Wrap(
          spacing: 4.w,
          runSpacing: 4.h,
          children: controller.customWords.map((w) => _buildCustomChip(w)).toList(),
        )),
        SizedBox(height: 12.h),
        _buildCustomInput(),
      ],
    );
  }
  Widget _buildCategoryLabel(String name, {required bool isCustom}) {
    final label = Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 2.h),
      child: Text(
        name.toUpperCase(),
        style: ConfettiFonts.outfit(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isCustom ? AppColors.secondary : AppColors.textTertiary,
        ),
      ),
    );
    if (isCustom) return label;
    return GestureDetector(
      onLongPress: () => controller.toggleCategory(name),
      child: label,
    );
  }
  Widget _buildChipRow(String category, List<String> words) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Obx(() => Row(
        children: words.map((w) => _buildChip(category, w)).toList(),
      )),
    );
  }
  Widget _buildChip(String category, String word) {
    final isOn = controller.isSelected(category, word);
    return GestureDetector(
      onTap: () => controller.toggleWord(category, word),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(right: 4.w, top: 3.h, bottom: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isOn ? AppColors.primary : AppColors.backgroundMuted,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isOn ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          word,
          style: ConfettiFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isOn ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
  Widget _buildCustomChip(String word) {
    final isOn = controller.isSelected(
      ConfettiWordJarLogic.customCategory,
      word,
    );
    return GestureDetector(
      onTap: () => controller.toggleWord(
        ConfettiWordJarLogic.customCategory,
        word,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(right: 4.w, top: 3.h, bottom: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isOn ? AppColors.secondaryLight : AppColors.backgroundMuted,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isOn ? AppColors.secondary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: ConfettiFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isOn
                    ? const Color(0xFF2A6B5C)
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 5.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isOn ? AppColors.secondary : AppColors.textTertiary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Custom',
                style: ConfettiFonts.outfit(
                  fontSize: 9.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCustomInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundMuted,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.customInput,
              style: ConfettiFonts.outfit(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Add your own word...',
                hintStyle: ConfettiFonts.outfit(
                  fontSize: 13.sp,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => controller.addCustomWord(),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.addCustomWord,
            child: Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.add, size: 13.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomCta() {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 34.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.36],
          colors: [Colors.transparent, AppColors.background],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConfettiWordJarTray(controller: controller),
          Obx(() {
            final n = controller.totalSelected;
            return Opacity(
              opacity: n > 0 ? 1 : 0.38,
              child: ConfettiBtnStamp(
                text: n > 0
                    ? 'Shred $n word${n == 1 ? '' : 's'}'
                    : 'Pick words first',
                fontSize: 16,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                width: double.infinity,
                onTap: controller.shred,
              ),
            );
          }),
        ],
      ),
    );
  }
}
