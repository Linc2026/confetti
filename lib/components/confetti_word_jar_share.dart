import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/confetti_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_colors.dart';
import '../utils/index.dart';
const Duration kWordJarShareFxDuration = Duration(milliseconds: 780);
class ConfettiWordJarShareCard extends StatelessWidget {
  final String quote;
  const ConfettiWordJarShareCard({super.key, required this.quote});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 420,
      child: ColoredBox(
        color: const Color(0xFFF4D9B8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/illustrations/ill_word_jar.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\u201C',
                style: ConfettiFonts.fraunces(
                  fontSize: 28,
                  color: AppColors.textPrimary.withOpacity(0.22),
                  height: 0.7,
                ),
              ),
              Text(
                quote,
                textAlign: TextAlign.center,
                style: ConfettiFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  height: 1.45,
                  color: AppColors.textPrimary.withOpacity(0.62),
                ),
              ),
              Text(
                '\u201D',
                style: ConfettiFonts.fraunces(
                  fontSize: 28,
                  color: AppColors.textPrimary.withOpacity(0.22),
                  height: 0.7,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confetti · Word Jar',
                style: ConfettiFonts.outfit(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ConfettiWordJarShareFx extends StatefulWidget {
  const ConfettiWordJarShareFx({super.key});
  @override
  State<ConfettiWordJarShareFx> createState() => _ConfettiWordJarShareFxState();
}
class _DropChip {
  final String word;
  final double startX;
  final double sway;
  final double delay;
  final Color color;
  const _DropChip({
    required this.word,
    required this.startX,
    required this.sway,
    required this.delay,
    required this.color,
  });
}
class _ConfettiWordJarShareFxState extends State<ConfettiWordJarShareFx>
    with SingleTickerProviderStateMixin {
  static const _words = [
    'Let go', 'Lighter', 'Free', 'Exhale', 'Safe', 'Finally',
  ];
  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    Color(0xFFC9A05A),
  ];
  late final AnimationController _ctrl;
  late final List<_DropChip> _chips;
  @override
  void initState() {
    super.initState();
    final rng = Random(7);
    _chips = List.generate(_words.length, (i) {
      return _DropChip(
        word: _words[i],
        startX: 0.18 + rng.nextDouble() * 0.64,
        sway: (rng.nextDouble() - 0.5) * 36,
        delay: i * 0.05,
        color: _colors[i % _colors.length],
      );
    });
    _ctrl = AnimationController(vsync: this, duration: kWordJarShareFxDuration)
      ..forward();
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = _ctrl.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              final mouth = Offset(size.width * 0.5, size.height * 0.36);
              return Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: (t * 2).clamp(0.0, 0.28),
                    child: const ColoredBox(color: Color(0xFFF4D9B8)),
                  ),
                  Align(
                    alignment: const Alignment(0, -0.28),
                    child: Opacity(
                      opacity: Curves.easeOut.transform((t / 0.2).clamp(0.0, 1.0)),
                      child: Transform.scale(
                        scale: 0.9 + Curves.easeOutBack.transform(
                              (t / 0.35).clamp(0.0, 1.0),
                            ) *
                            0.1,
                        child: Image.asset(
                          'assets/illustrations/ill_word_jar.png',
                          width: 220.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  ..._chips.map((c) => _buildDrop(c, size, mouth, t)),
                ],
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildDrop(_DropChip chip, Size size, Offset mouth, double t) {
    final local = ((t - chip.delay) / (1 - chip.delay)).clamp(0.0, 1.0);
    if (local <= 0) return const SizedBox.shrink();
    final fall = Curves.easeInCubic.transform(local);
    final start = Offset(size.width * chip.startX, -24);
    final mid = Offset(
      mouth.dx + chip.sway,
      size.height * 0.18,
    );
    final pos = local < 0.45
        ? Offset.lerp(start, mid, local / 0.45)!
        : Offset.lerp(mid, mouth, (local - 0.45) / 0.55)!;
    final fade = local < 0.72 ? 1.0 : (1 - (local - 0.72) / 0.28);
    final scale = 1.0 - fall * 0.45;
    return Positioned(
      left: pos.dx - 36.w,
      top: pos.dy - 12.h,
      child: Opacity(
        opacity: fade.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: chip.sway * 0.02 * (1 - local),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: chip.color,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: chip.color.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                chip.word,
                style: ConfettiFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
Future<void> shareWordJarCard({
  required GlobalKey cardKey,
  required String quote,
}) async {
  const captionTail = '\n\n— Confetti · Word Jar';
  final caption = '"$quote"$captionTail';
  try {
    await HapticFeedback.mediumImpact();
    final ctx = cardKey.currentContext;
    final boundary = ctx?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      await Share.share(caption);
      return;
    }
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) {
      await Share.share(caption);
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/confetti_word_jar.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path)], text: caption);
  } catch (_) {
    try {
      await Share.share(caption);
    } catch (_) {
      errorToast('Could not share right now.');
    }
  }
}
