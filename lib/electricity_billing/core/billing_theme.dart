import 'package:flutter/material.dart';

class BillingTheme {
  static const Color electricBlue = Color(0xFF0B5FFF);
  static const Color powerOrange = Color(0xFFFFB020);
  static const Color deepNavy = Color(0xFF071A2E);
  static const Color successGreen = Color(0xFF17A34A);

  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: electricBlue,
      brightness: brightness,
      primary: electricBlue,
      secondary: powerOrange,
      tertiary: successGreen,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Tajawal',
      scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF07111F) : const Color(0xFFF5F8FC),
      appBarTheme: AppBarTheme(centerTitle: true, elevation: 0, backgroundColor: Colors.transparent, foregroundColor: scheme.onSurface),
      cardTheme: CardTheme(elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }
}
