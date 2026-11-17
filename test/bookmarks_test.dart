import 'package:flutter_quiz_300/domain/bookmarks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final bank = sampleBank(); // mã câu 1, 2, 3

  test('trả về các câu đã đánh dấu theo thứ tự mã câu', () {
    expect(bookmarkedQuestions(bank, {3, 1}).map((q) => q.id), [1, 3]);
  });

  test('chưa đánh dấu thì rỗng', () {
    expect(bookmarkedQuestions(bank, {}), isEmpty);
  });

  test('bỏ qua mã không còn trong ngân hàng', () {
    expect(bookmarkedQuestions(bank, {2, 999}).map((q) => q.id), [2]);
  });
}
