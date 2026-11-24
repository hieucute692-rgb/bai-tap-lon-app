import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: brightness,
  ).copyWith(
    surface: isLight ? Colors.white : const Color(0xFF181B24),
    surfaceContainerLowest: isLight ? Colors.white : const Color(0xFF181B24),
    surfaceContainerHighest:
        isLight ? const Color(0xFFEEF1F6) : const Color(0xFF0E1017),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
