import 'package:flutter_quiz_300/data/shared_prefs_bookmark_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('chưa lưu thì trả về rỗng', () async {
    expect(await SharedPrefsBookmarkRepository().loadBookmarks(), isEmpty);
  });

  test('lưu rồi đọc lại đúng các câu đã đánh dấu', () async {
    await SharedPrefsBookmarkRepository().saveBookmarks({12, 3, 250});
    expect(await SharedPrefsBookmarkRepository().loadBookmarks(), {3, 12, 250});
  });

  test('dữ liệu hỏng không làm app dừng, trả về rỗng', () async {
    SharedPreferences.setMockInitialValues({SharedPrefsBookmarkRepository.key: 'không phải json'});
    expect(await SharedPrefsBookmarkRepository().loadBookmarks(), isEmpty);

    SharedPreferences.setMockInitialValues({SharedPrefsBookmarkRepository.key: '["a", "b"]'});
    expect(await SharedPrefsBookmarkRepository().loadBookmarks(), isEmpty);
  });
}
