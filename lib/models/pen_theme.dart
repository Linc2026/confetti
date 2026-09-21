import 'package:flutter/material.dart';
class PenTheme {
  final String id;
  final String name;
  final Color swatch;
  final Color paper;
  final Color ink;
  final String paperImage;
  const PenTheme({
    required this.id,
    required this.name,
    required this.swatch,
    required this.paper,
    required this.ink,
    required this.paperImage,
  });
}
const List<PenTheme> kPenThemes = [
  PenTheme(
    id: 'crispyBlank',
    name: 'Crispy · Blank',
    swatch: Color(0xFFFFF3B0),
    paper: Color(0xFFFFF8DC),
    ink: Color(0xFF2A261F),
    paperImage: 'assets/illustrations/ill_write.png',
  ),
  PenTheme(
    id: 'deepAutumn',
    name: 'Deep · Autumn',
    swatch: Color(0xFF8B5A2B),
    paper: Color(0xFFC9A05A),
    ink: Color(0xFF3A2410),
    paperImage: 'assets/illustrations/ill_write_autumn.jpg',
  ),
  PenTheme(
    id: 'softDissolve',
    name: 'Soft · Dissolve',
    swatch: Color(0xFFF5C4CE),
    paper: Color(0xFFF8DDE3),
    ink: Color(0xFF4A2A32),
    paperImage: 'assets/illustrations/ill_write_dissolve.jpg',
  ),
  PenTheme(
    id: 'clickBird',
    name: 'Click · Bird',
    swatch: Color(0xFFC5E6C8),
    paper: Color(0xFFE4F4E6),
    ink: Color(0xFF243528),
    paperImage: 'assets/illustrations/ill_write_bird.jpg',
  ),
  PenTheme(
    id: 'crackFrost',
    name: 'Crack · Frost',
    swatch: Color(0xFFC8D9EE),
    paper: Color(0xFFE8F0F8),
    ink: Color(0xFF1E2A38),
    paperImage: 'assets/illustrations/ill_write_frost.jpg',
  ),
  PenTheme(
    id: 'snowWhite',
    name: 'Snow · White',
    swatch: Color(0xFFFFFFFF),
    paper: Color(0xFFFFFFFF),
    ink: Color(0xFF1C1917),
    paperImage: 'assets/illustrations/ill_write_snow.jpg',
  ),
];
PenTheme penThemeById(String id) {
  return kPenThemes.firstWhere(
    (t) => t.id == id,
    orElse: () => kPenThemes.first,
  );
}
