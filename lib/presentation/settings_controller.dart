import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/study_notification_service.dart';
import '../domain/app_strings.dart';
import '../domain/question.dart';
import '../domain/settings_repository.dart';

/// Ngôn ngữ, giao diện và cài đặt thông báo dùng chung cho toàn app.
class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  static const String _notificationEnabledKey = 'daily_study_notifications_enabled';

  final SettingsRepository _repository;

  ContentLanguage _language = ContentLanguage.vi;
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _disposed = false;

  ContentLanguage get language => _language;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  AppStrings get strings => AppStrings(_language);

  Future<void> load() async {
    try {
      final saved = await _repository.loadLanguage();
      if (saved != null && saved != _language) {
        _language = saved;
      }
      final savedThemeMode = await _repository.loadThemeMode();
      if (savedThemeMode != null && savedThemeMode != _themeMode) {
        _themeMode = savedThemeMode;
      }

      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationEnabledKey) ?? true;
      _notify();
    } catch (e, st) {
      debugPrint('Không đọc được cài đặt: $e\n$st');
    }
  }

  Future<void> setLanguage(ContentLanguage language) async {
    if (language == _language) return;
    _language = language;
    _notify();
    try {
      await _repository.saveLanguage(language);
    } catch (e, st) {
      debugPrint('Không lưu được cài đặt ngôn ngữ: $e\n$st');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _notify();
    try {
      await _repository.saveThemeMode(mode);
    } catch (e, st) {
      debugPrint('Could not save theme mode: $e\n$st');
    }
  }

  /// Bật/tắt thông báo nhắc chỉ tiêu & giữ chuỗi.
  /// Trả về `false` nếu người dùng từ chối quyền thông báo trên máy.
  Future<bool> setNotificationsEnabled({
    required bool enabled,
    required int dailyGoal,
    required int todayAnsweredCount,
    required int currentStreak,
  }) async {
    if (enabled) {
      final granted =
      await StudyNotificationService.instance.requestPermissionIfNeeded();
      if (!granted) {
        _notificationsEnabled = false;
        _notify();
        return false;
      }
    }

    _notificationsEnabled = enabled;
    _notify();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, enabled);
    } catch (e, st) {
      debugPrint('Không lưu được trạng thái thông báo: $e\n$st');
    }

    if (enabled) {
      await StudyNotificationService.instance.scheduleDailyReminders(
        dailyGoal: dailyGoal,
        todayAnsweredCount: todayAnsweredCount,
        currentStreak: currentStreak,
        isVietnamese: _language == ContentLanguage.vi,
      );
    } else {
      await StudyNotificationService.instance.cancelAllReminders();
    }

    return true;
  }

  /// Gửi thông báo test ngay lập tức để kiểm tra hiển thị trên màn hình.
  Future<bool> sendTestNotification({
    required int dailyGoal,
    required int todayAnsweredCount,
    required int currentStreak,
  }) async {
    final granted =
    await StudyNotificationService.instance.requestPermissionIfNeeded();
    if (!granted) return false;

    await StudyNotificationService.instance.showTestNotification(
      dailyGoal: dailyGoal,
      todayAnsweredCount: todayAnsweredCount,
      currentStreak: currentStreak,
      isVietnamese: _language == ContentLanguage.vi,
    );
    return true;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}