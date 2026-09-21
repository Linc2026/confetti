import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../utils/index.dart';
class ConfettiAboutLogic extends GetxController {
  final appVersion = 'Version 1.0.0'.obs;
  @override
  void onInit() {
    super.onInit();
    _loadVersion();
  }
  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = 'Version ${info.version}';
    } catch (_) {
      appVersion.value = 'Version 1.0.0';
    }
  }
  void onBackTap() => Get.back();
  Future<void> onRateTap() async {
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await review.openStoreListing();
      }
    } catch (_) {
      errorToast(GetPlatform.isIOS
          ? 'Could not open App Store.'
          : 'Could not open Google Play.');
    }
  }
}
