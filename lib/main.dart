import 'package:confetti/pages/confetti_round/confetti_round_binding.dart';
import 'package:confetti/pages/confetti_round/confetti_round_view.dart';
import 'package:confetti/pages/confetti_splash/confetti_splash_view.dart';
import 'package:confetti/pages/confetti_write/confetti_write_send.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'db_confetti/data.dart';
import '../pages/confetti_splash/confetti_splash_binding.dart';
import '../pages/confetti_home/confetti_home_binding.dart';
import '../pages/confetti_home/confetti_home_view.dart';
import '../pages/confetti_write/confetti_write_binding.dart';
import '../pages/confetti_write/confetti_write_view.dart';
import '../pages/confetti_about/confetti_about_binding.dart';
import '../pages/confetti_about/confetti_about_view.dart';
import '../pages/confetti_doodle/confetti_doodle_binding.dart';
import '../pages/confetti_doodle/confetti_doodle_view.dart';
import '../pages/confetti_word_jar/confetti_word_jar_binding.dart';
import '../pages/confetti_word_jar/confetti_word_jar_view.dart';
import '../pages/confetti_rage_tap/confetti_rage_tap_binding.dart';
import '../pages/confetti_rage_tap/confetti_rage_tap_view.dart';
import '../pages/confetti_countdown/confetti_countdown_binding.dart';
import '../pages/confetti_countdown/confetti_countdown_view.dart';
import 'utils/confetti_timezone.dart';
import 'utils/app_colors.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalTimezone();
  await Get.putAsync(() => ConfettiDatabase().init());
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const ConfettiApp());
}
class ConfettiApp extends StatelessWidget {
  const ConfettiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Confetti',
          getPages: Emotional,
          initialBinding: ConfettiRoundBinding(),
          initialRoute: '/',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Emotional = [
  GetPage(
    name: '/',
    page: () => const ConfettiRoundView(),
    binding: ConfettiRoundBinding(),
  ),
  GetPage(
    name: '/con_splash',
    page: () => const ConfettiSplashView(),
    binding: ConfettiSplashBinding(),
  ),
  GetPage(
    name: '/con_home',
    page: () => const ConfettiHomeView(),
    binding: ConfettiHomeBinding(),
  ),
  GetPage(
    name: '/con_write',
    page: () => const ConfettiWriteView(),
    binding: ConfettiWriteBinding(),
  ),
  GetPage(
    name: '/con_write_send',
    page: () => const ConfettiWriteSend(),
  ),
  GetPage(
    name: '/con_about',
    page: () => const ConfettiAboutView(),
    binding: ConfettiAboutBinding(),
  ),
  GetPage(
    name: '/con_doodle',
    page: () => const ConfettiDoodleView(),
    binding: ConfettiDoodleBinding(),
  ),
  GetPage(
    name: '/con_word_jar',
    page: () => const ConfettiWordJarView(),
    binding: ConfettiWordJarBinding(),
  ),
  GetPage(
    name: '/con_rage_tap',
    page: () => const ConfettiRageTapView(),
    binding: ConfettiRageTapBinding(),
  ),
  GetPage(
    name: '/con_countdown',
    page: () => const ConfettiCountdownView(),
    binding: ConfettiCountdownBinding(),
  ),
];