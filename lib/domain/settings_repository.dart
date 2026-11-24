import 'package:flutter/material.dart';

import 'question.dart';

/// Nơi lưu cài đặt ngôn ngữ và giao diện người dùng.
abstract class SettingsRepository {
  /// Ngôn ngữ đã lưu, hoặc null nếu chưa lưu / giá trị không hợp lệ.
  Future<ContentLanguage?> loadLanguage();
  Future<void> saveLanguage(ContentLanguage language);
  Future<ThemeMode?> loadThemeMode() async => null;
  Future<void> saveThemeMode(ThemeMode mode) async {}
}
