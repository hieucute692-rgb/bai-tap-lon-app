import 'package:shared_preferences/shared_preferences.dart';

import '../domain/question.dart';
import '../domain/settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const languageKey = 'language_v1';

  @override
  Future<ContentLanguage?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(languageKey)) {
      'vi' => ContentLanguage.vi,
      'en' => ContentLanguage.en,
      _ => null, // chưa lưu hoặc dữ liệu lạ: dùng mặc định
    };
  }

  @override
  Future<void> saveLanguage(ContentLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, language.name);
  }
}
