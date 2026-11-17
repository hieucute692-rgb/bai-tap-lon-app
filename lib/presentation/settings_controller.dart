import 'package:flutter/foundation.dart';

import '../domain/question.dart';
import '../domain/settings_repository.dart';

/// Ngôn ngữ hiển thị nội dung câu hỏi dùng chung cho cả app: chọn ở trang chủ,
/// đổi nhanh được trong lúc làm bài, và được nhớ sau khi thoát app.
class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  ContentLanguage _language = ContentLanguage.vi;
  bool _disposed = false;

  ContentLanguage get language => _language;

  Future<void> load() async {
    try {
      final saved = await _repository.loadLanguage();
      if (saved != null && saved != _language) {
        _language = saved;
        _notify();
      }
    } catch (e, st) {
      debugPrint('Không đọc được cài đặt ngôn ngữ: $e\n$st');
    }
  }

  /// Đổi ngôn ngữ ngay; nếu không lưu được thì vẫn dùng ngôn ngữ mới cho tới khi thoát app.
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

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
