import 'package:flutter_quiz_300/domain/practice_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('chọn đúng/sai và chỉ được chọn một lần mỗi câu', () {
    final s = PracticeSession(bankWithBlockSizes([2]).questions);
    expect(s.select(1), isFalse);
    expect(s.select(0), isNull); // đã trả lời, bỏ qua
    expect(s.chosen, 1);
  });

  test('phải trả lời mới sang câu tiếp, và dừng ở câu cuối', () {
    final s = PracticeSession(bankWithBlockSizes([2]).questions);
    expect(s.next(), isFalse);
    s.select(0);
    expect(s.next(), isTrue);
    expect(s.isLast, isTrue);
    s.select(0);
    expect(s.next(), isFalse);
  });

  test('đếm số câu đúng', () {
    final s = PracticeSession(bankWithBlockSizes([2]).questions);
    s.select(0);
    s.next();
    s.select(3);
    expect(s.correctCount, 1);
  });
}
