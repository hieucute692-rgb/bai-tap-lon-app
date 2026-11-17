import 'package:flutter_quiz_300/data/shared_prefs_settings_repository.dart';
import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('chưa lưu thì trả về null', () async {
    expect(await SharedPrefsSettingsRepository().loadLanguage(), isNull);
  });

  test('lưu rồi đọc lại đúng ngôn ngữ', () async {
    await SharedPrefsSettingsRepository().saveLanguage(ContentLanguage.en);
    expect(await SharedPrefsSettingsRepository().loadLanguage(), ContentLanguage.en);
    await SharedPrefsSettingsRepository().saveLanguage(ContentLanguage.vi);
    expect(await SharedPrefsSettingsRepository().loadLanguage(), ContentLanguage.vi);
  });

  test('giá trị lạ được bỏ qua', () async {
    SharedPreferences.setMockInitialValues({SharedPrefsSettingsRepository.languageKey: 'fr'});
    expect(await SharedPrefsSettingsRepository().loadLanguage(), isNull);
  });
}
