import 'package:flutter_quiz_300/domain/exam.dart';
import 'package:flutter_quiz_300/domain/progress.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('toJson/fromJson giữ nguyên đáp án từng câu, kể cả câu bỏ trống', () {
    final original = ExamResult(
      takenAt: DateTime(2026, 1, 2, 9, 30),
      total: 3,
      correct: 1,
      answers: const [
        ExamAnswer(questionId: 4, chosen: 0),
        ExamAnswer(questionId: 9, chosen: 3),
        ExamAnswer(questionId: 12, chosen: null),
      ],
    );
    final copy = ExamResult.fromJson(original.toJson());
    expect(copy.takenAt, original.takenAt);
    expect(copy.answers.map((a) => a.questionId), [4, 9, 12]);
    expect(copy.answers.map((a) => a.chosen), [0, 3, null]);
    expect(copy.hasDetails, isTrue);
  });

  test('bản lưu cũ không có answers vẫn đọc được nhưng không có chi tiết', () {
    final r = ExamResult.fromJson({
      'taken_at': '2026-01-01T08:00:00.000',
      'total': 30,
      'correct': 24,
    });
    expect(r.correct, 24);
    expect(r.answers, isEmpty);
    expect(r.hasDetails, isFalse);
  });

  test('ExamSession.toResult ghi đáp án từng câu theo thứ tự trong bài', () {
    final bank = bankWithBlockSizes([3]);
    final session = ExamSession(bank.questions);
    session.answer(bank.questions[0], 0);
    session.answer(bank.questions[1], 2);

    final result = session.toResult(DateTime(2026, 1, 1));
    expect(result.answers.map((a) => a.questionId), [1, 2, 3]);
    expect(result.answers.map((a) => a.chosen), [0, 2, null]);
    expect(result.correct, 1);
  });
}
