import 'package:flutter_quiz_300/presentation/bookmark_controller.dart';
import 'package:flutter_quiz_300/presentation/question_bank_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('chưa tải xong thì ở trạng thái loading, tải xong khôi phục danh sách', () async {
    final c = BookmarkController(FakeBookmarkRepository(saved: {4, 9}));
    expect(c.status, LoadStatus.loading);
    await c.load();
    expect(c.status, LoadStatus.ready);
    expect(c.ids, {4, 9});
    expect(c.count, 2);
  });

  test('toggle: đánh dấu rồi bỏ đánh dấu, có lưu xuống repository', () async {
    final repo = FakeBookmarkRepository();
    final c = BookmarkController(repo);
    await c.toggle(5);
    expect(c.isBookmarked(5), isTrue);
    expect(repo.saved, {5});

    await c.toggle(5);
    expect(c.isBookmarked(5), isFalse);
    expect(repo.saved, isEmpty);
  });

  test('toggle thông báo cho giao diện vẽ lại', () async {
    final c = BookmarkController(FakeBookmarkRepository());
    var notified = 0;
    c.addListener(() => notified++);
    await c.toggle(1);
    expect(notified, greaterThanOrEqualTo(1));
  });

  test('lỗi ghi: vẫn giữ trong bộ nhớ và báo problem', () async {
    final c = BookmarkController(FakeBookmarkRepository(failSave: true));
    await c.toggle(7);
    expect(c.isBookmarked(7), isTrue);
    expect(c.problem, BookmarkProblem.saveFailed);
  });

  test('lỗi đọc: bắt đầu từ rỗng, báo problem, app vẫn sẵn sàng', () async {
    final c = BookmarkController(FakeBookmarkRepository(failLoad: true));
    await c.load();
    expect(c.status, LoadStatus.ready);
    expect(c.ids, isEmpty);
    expect(c.problem, BookmarkProblem.loadFailed);
  });

  test('ids trả về bản không sửa được', () async {
    final c = BookmarkController(FakeBookmarkRepository(saved: {1}));
    await c.load();
    expect(() => c.ids.add(2), throwsUnsupportedError);
  });
}
