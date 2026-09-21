import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/confetti_fonts.dart';
import '../db_confetti/db_confetti_entity.dart';
import '../models/pen_theme.dart';
import 'confetti_btn_stamp.dart';
import 'confetti_label_burst.dart';
import 'confetti_paper_fill.dart';
import 'confetti_quote_share.dart';
import 'confetti_shred_fx.dart';
import 'confetti_word_burst.dart';
import 'confetti_word_jar_share.dart';
class ConfettiShredOverlay extends StatelessWidget {
  final int particleCount;
  final double flashOpacity;
  final String themeId;
  final String mode;
  final String paperImage;
  final ImageProvider? burstImage;
  final List<String> words;
  final String? burstLabel;
  const ConfettiShredOverlay({
    super.key,
    required this.particleCount,
    required this.flashOpacity,
    this.themeId = 'crispyBlank',
    this.mode = ConfettiShredMode.physicalDegradation,
    this.paperImage = 'assets/illustrations/ill_write.png',
    this.burstImage,
    this.words = const [],
    this.burstLabel,
  });
  @override
  Widget build(BuildContext context) {
    final theme = penThemeById(themeId);
    final energy = burstLabel != null && burstLabel!.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (energy) ...[
          Image.asset(
            'assets/illustrations/ill_rage_tap.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.34),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.12),
                radius: 1.05,
                colors: [Color(0x332A221C), Color(0xF21E1B18)],
              ),
            ),
            child: SizedBox.expand(),
          ),
        ] else
          ConfettiPaperFill(asset: paperImage),
        if (energy)
          ConfettiLabelBurst(label: burstLabel!)
        else if (words.isNotEmpty)
          ConfettiWordBurst(words: words)
        else
          _PaperBurst(paperImage: paperImage, burstImage: burstImage),
        if (!energy)
          ConfettiShredFx(
            themeId: themeId,
            mode: mode,
            particleCount: particleCount,
          ),
        if (!energy)
          _FlashOverlay(color: theme.paper, flashOpacity: flashOpacity),
        if (!energy)
          Positioned(
            top: 89.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Shredding...',
                style: ConfettiFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: theme.ink.withOpacity(0.45),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
class ConfettiDoneOverlay extends StatefulWidget {
  final String quote;
  final VoidCallback onOk;
  final VoidCallback? onAgain;
  final String againLabel;
  final String? energyLabel;
  final bool jarShare;
  final String themeId;
  final String paperImage;
  const ConfettiDoneOverlay({
    super.key,
    required this.quote,
    required this.onOk,
    this.onAgain,
    this.againLabel = 'Draw another',
    this.energyLabel,
    this.jarShare = false,
    this.themeId = 'crispyBlank',
    this.paperImage = 'assets/illustrations/ill_write.png',
  });
  @override
  State<ConfettiDoneOverlay> createState() => _ConfettiDoneOverlayState();
}
class _ConfettiDoneOverlayState extends State<ConfettiDoneOverlay> {
  final _cardKey = GlobalKey();
  bool _sharing = false;
  bool _jarFx = false;
  Future<void> _onShare() async {
    if (_sharing) return;
    _sharing = true;
    if (widget.jarShare) {
      setState(() => _jarFx = true);
      await Future.delayed(kWordJarShareFxDuration);
      if (!mounted) return;
      setState(() => _jarFx = false);
      await shareWordJarCard(cardKey: _cardKey, quote: widget.quote);
    } else {
      await shareQuoteCard(
        cardKey: _cardKey,
        quote: widget.quote,
        energyLabel: widget.energyLabel,
      );
    }
    _sharing = false;
  }
  @override
  Widget build(BuildContext context) {
    final theme = penThemeById(widget.themeId);
    return Stack(
      fit: StackFit.expand,
      children: [
        ConfettiPaperFill(asset: widget.paperImage),
        Transform.translate(
          offset: const Offset(-4000, 0),
          child: RepaintBoundary(
            key: _cardKey,
            child: widget.jarShare
                ? ConfettiWordJarShareCard(quote: widget.quote)
                : ConfettiQuoteShareCard(
                    quote: widget.quote,
                    paperImage: widget.paperImage,
                    themeId: widget.themeId,
                    energyLabel: widget.energyLabel,
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\u201C',
                style: ConfettiFonts.fraunces(
                  fontSize: 42.sp,
                  color: theme.ink.withOpacity(0.22),
                  height: 0.8,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.quote,
                textAlign: TextAlign.center,
                style: ConfettiFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontSize: 22.sp,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  color: theme.ink.withOpacity(0.62),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '\u201D',
                style: ConfettiFonts.fraunces(
                  fontSize: 42.sp,
                  color: theme.ink.withOpacity(0.22),
                  height: 0.8,
                ),
              ),
              SizedBox(height: 28.h),
              GestureDetector(
                onTap: _onShare,
                child: Text(
                  'Share the words',
                  style: ConfettiFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: theme.ink.withOpacity(0.45),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ConfettiBtnStamp(
                text: '[ OK ]',
                dark: true,
                fontSize: 16,
                padding: EdgeInsets.symmetric(horizontal: 52.w, vertical: 16.h),
                onTap: widget.onOk,
              ),
              if (widget.onAgain != null) ...[
                SizedBox(height: 14.h),
                GestureDetector(
                  onTap: widget.onAgain,
                  child: Text(
                    widget.againLabel,
                    style: ConfettiFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: theme.ink.withOpacity(0.45),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_jarFx) const ConfettiWordJarShareFx(),
      ],
    );
  }
}
class _PaperBurst extends StatefulWidget {
  final String paperImage;
  final ImageProvider? burstImage;
  const _PaperBurst({required this.paperImage, this.burstImage});
  @override
  State<_PaperBurst> createState() => _PaperBurstState();
}
class _PaperBurstState extends State<_PaperBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
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
        builder: (_, __) {
          final t = _ctrl.value;
          final scale = t < 0.22
              ? 0.88 + (t / 0.22) * 0.2
              : 1.08 + ((t - 0.22) / 0.78) * 0.55;
          final opacity = t < 0.18
              ? t / 0.18
              : (1 - (t - 0.18) / 0.82).clamp(0.0, 1.0);
          return Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: t * 0.08,
                child: Transform.scale(
                  scale: scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: SizedBox(
                      width: widget.burstImage != null ? 320.w : 220.w,
                      height: widget.burstImage != null ? 420.h : 280.h,
                      child: ConfettiPaperFill(
                        asset: widget.paperImage,
                        image: widget.burstImage,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class _FlashOverlay extends StatefulWidget {
  final Color color;
  final double flashOpacity;
  const _FlashOverlay({
    required this.color,
    required this.flashOpacity,
  });
  @override
  State<_FlashOverlay> createState() => _FlashOverlayState();
}
class _FlashOverlayState extends State<_FlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = Tween<double>(begin: widget.flashOpacity, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fade,
      builder: (_, __) => IgnorePointer(
        child: Container(
          color: widget.color.withOpacity(_fade.value),
        ),
      ),
    );
  }
}
