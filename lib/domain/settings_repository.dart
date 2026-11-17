import 'question.dart';

/// Nơi lưu cài đặt người dùng (hiện chỉ có ngôn ngữ hiển thị nội dung câu hỏi).
abstract class SettingsRepository {
  /// Ngôn ngữ đã lưu, hoặc null nếu chưa lưu / giá trị không hợp lệ.
  Future<ContentLanguage?> loadLanguage();
  Future<void> saveLanguage(ContentLanguage language);
}
