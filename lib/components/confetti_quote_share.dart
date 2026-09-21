import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/confetti_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/pen_theme.dart';
import '../utils/index.dart';
import 'confetti_paper_fill.dart';
class ConfettiQuoteShareCard extends StatelessWidget {
  final String quote;
  final String paperImage;
  final String themeId;
  final String? energyLabel;
  const ConfettiQuoteShareCard({
    super.key,
    required this.quote,
    required this.paperImage,
    required this.themeId,
    this.energyLabel,
  });
  @override
  Widget build(BuildContext context) {
    final theme = penThemeById(themeId);
    return SizedBox(
      width: 320,
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ConfettiPaperFill(asset: paperImage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (energyLabel != null && energyLabel!.isNotEmpty) ...[
                  Text(
                    energyLabel!,
                    style: ConfettiFonts.fraunces(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.ink.withOpacity(0.55),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  '\u201C',
                  style: ConfettiFonts.fraunces(
                    fontSize: 36,
                    color: theme.ink.withOpacity(0.22),
                    height: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: ConfettiFonts.fraunces(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    height: 1.5,
                    color: theme.ink.withOpacity(0.62),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\u201D',
                  style: ConfettiFonts.fraunces(
                    fontSize: 36,
                    color: theme.ink.withOpacity(0.22),
                    height: 0.8,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Confetti',
                  style: ConfettiFonts.outfit(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: theme.ink.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> shareQuoteCard({
  required GlobalKey cardKey,
  required String quote,
  String? energyLabel,
}) async {
  final caption = energyLabel != null && energyLabel.isNotEmpty
      ? '$energyLabel\n"$quote"\n\n— Confetti'
      : '"$quote"\n\n— Confetti';
  try {
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
    final file = File('${dir.path}/confetti_quote.png');
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
