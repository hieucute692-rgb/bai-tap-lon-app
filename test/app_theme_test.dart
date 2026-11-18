import 'package:flutter/material.dart';
import 'package:flutter_quiz_300/presentation/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('chủ đề dùng màu chính và nền của hướng A', () {
    final theme = buildAppTheme();
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
  });

  test('chữ trên nền đạt tương phản tối thiểu 4,5:1', () {
    final pairs = <String, (Color, Color)>{
      'chữ chính trên nền': (AppColors.ink, AppColors.canvas),
      'chữ phụ trên nền': (AppColors.muted, AppColors.canvas),
      'chữ phụ trên nền trắng': (AppColors.muted, Colors.white),
      'chữ trắng trên thẻ chính': (Colors.white, AppColors.primary),
      'chữ phụ trên thẻ chính': (AppColors.onPrimarySoft, AppColors.primary),
      'chữ trên lựa chọn đang chọn': (AppColors.ink, AppColors.selectedTint),
      'chữ trắng trên huy hiệu': (Colors.white, AppColors.ink),
    };
    for (final tile in [
      AppColors.exam,
      AppColors.stats,
      AppColors.retry,
      AppColors.bookmark,
    ]) {
      pairs['chữ chính trên thẻ ${tile.background}'] = (AppColors.ink, tile.background);
      pairs['chữ phụ trên thẻ ${tile.background}'] = (tile.subtitle, tile.background);
    }
    pairs.forEach((name, pair) {
      expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5), reason: name);
    });
  });

  test('biểu tượng trên thẻ đạt tương phản tối thiểu 3:1', () {
    for (final tile in [
      AppColors.exam,
      AppColors.stats,
      AppColors.retry,
      AppColors.bookmark,
    ]) {
      expect(
        contrast(tile.icon, tile.background),
        greaterThanOrEqualTo(3),
        reason: 'thẻ ${tile.background}',
      );
    }
  });
}
