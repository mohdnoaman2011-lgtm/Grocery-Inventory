import 'package:flutter/material.dart';

const kGreen = Color(0xFF1F6F54);
const kGreenDark = Color(0xFF12483A);

ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(seedColor: kGreen, brightness: b);
  final light = b == Brightness.light;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: light ? const Color(0xFFF4F8F5) : const Color(0xFF0F1512),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: light ? Colors.white : const Color(0xFF18201C),
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStatePropertyAll(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
