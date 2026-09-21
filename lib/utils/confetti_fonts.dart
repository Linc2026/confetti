import 'package:flutter/material.dart';
class ConfettiFonts {
  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Outfit',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
    );
  }
  static TextStyle fraunces({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
  }) {
    return TextStyle(
      fontFamily: 'Fraunces',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      shadows: shadows,
      fontFeatures: fontFeatures,
    );
  }
}
