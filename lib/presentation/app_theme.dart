import 'package:flutter/material.dart';

/// Màu của giao diện (hướng A: sáng, thẻ lưới). Mọi cặp chữ/nền đều đã kiểm tra độ tương
/// phản (xem test/app_theme_test.dart): chữ từ 4,5:1 trở lên, biểu tượng từ 3:1.
abstract final class AppColors {
  static const ink = Color(0xFF1B1F3B);
  static const muted = Color(0xFF4A5070);
  static const primary = Color(0xFF4338CA);
  static const onPrimarySoft = Color(0xFFE0E7FF);
  static const canvas = Color(0xFFF5F6FB);
  static const outline = Color(0xFFDDE1F2);
  static const selectedTint = Color(0xFFE0E7FF);
  static const translucentWhite = Color(0x2EFFFFFF);

  static const exam = TileColors(
    background: Color(0xFFFFE8D6),
    icon: Color(0xFF9A3412),
    subtitle: Color(0xFF4A5070),
  );
  static const stats = TileColors(
    background: Color(0xFFD8F3E6),
    icon: Color(0xFF166534),
    subtitle: Color(0xFF3F5A4C),
  );
  static const retry = TileColors(
    background: Color(0xFFFFE0E3),
    icon: Color(0xFF9F1239),
    subtitle: Color(0xFF6B3A44),
  );
  static const bookmark = TileColors(
    background: Color(0xFFFFF3C4),
    icon: Color(0xFF854D0E),
    subtitle: Color(0xFF5E4A1E),
  );
}

/// Bộ ba màu của một thẻ trên trang chủ: nền, biểu tượng, chữ phụ.
class TileColors {
  const TileColors({
    required this.background,
    required this.icon,
    required this.subtitle,
  });

  final Color background;
  final Color icon;
  final Color subtitle;
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: AppColors.canvas,
    onSurface: AppColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
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
