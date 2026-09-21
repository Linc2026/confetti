import 'package:flutter/material.dart';
class ConfettiPaperFill extends StatelessWidget {
  final String? asset;
  final ImageProvider? image;
  const ConfettiPaperFill({
    super.key,
    this.asset,
    this.image,
  }) : assert(asset != null || image != null);
  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Image(
        image: image!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
      );
    }
    return Transform.scale(
      scale: 1.72,
      alignment: const Alignment(-0.04, 0.1),
      child: Image.asset(
        asset!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
