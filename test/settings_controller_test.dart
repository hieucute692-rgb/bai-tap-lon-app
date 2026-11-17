import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_quiz_300/presentation/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('mặc định là tiếng Việt', () {
    expect(SettingsController(FakeSettingsRepository()).language, ContentLanguage.vi);
  });

  test('khôi phục ngôn ngữ đã lưu', () async {
    final c = SettingsController(FakeSettingsRepository(saved: ContentLanguage.en));
    await c.load();
    expect(c.language, ContentLanguage.en);
  });

  test('đổi ngôn ngữ thì thông báo và lưu xuống repository', () async {
    final repo = FakeSettingsRepository();
    final c = SettingsController(repo);
    var notified = 0;
    c.addListener(() => notified++);

    await c.setLanguage(ContentLanguage.en);
    expect(c.language, ContentLanguage.en);
    expect(repo.saved, ContentLanguage.en);
    expect(notified, 1);

    await c.setLanguage(ContentLanguage.en); // không đổi thì không làm gì
    expect(notified, 1);
  });

  test('lỗi đọc: dùng mặc định, không ném lỗi', () async {
    final c = SettingsController(FakeSettingsRepository(failLoad: true));
    await c.load();
    expect(c.language, ContentLanguage.vi);
  });

  test('lỗi ghi: vẫn đổi ngôn ngữ trong phiên hiện tại', () async {
    final c = SettingsController(FakeSettingsRepository(failSave: true));
    await c.setLanguage(ContentLanguage.en);
    expect(c.language, ContentLanguage.en);
  });
}
