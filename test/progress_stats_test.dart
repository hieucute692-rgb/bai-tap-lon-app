import 'package:flutter_quiz_300/domain/progress.dart';
import 'package:flutter_quiz_300/domain/progress_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

QuestionStat stat(int id, {required int attempts, required int correct, required bool last}) =>
    QuestionStat(
      questionId: id,
      attempts: attempts,
      correct: correct,
      lastCorrect: last,
      lastAt: DateTime(2026, 1, 1),
    );

void main() {
  final bank = sampleBank(); // câu 1,2 thuộc khối 1; câu 3 thuộc khối 2

  test('thống kê theo khối', () {
    final stats = {
      1: stat(1, attempts: 2, correct: 1, last: false),
      2: stat(2, attempts: 1, correct: 1, last: true),
    };
    final p = computeBlockProgress(bank, stats);
    expect(p[0].answered, 2);
    expect(p[0].attempts, 3);
    expect(p[0].correct, 2);
    expect(p[0].wrong, 1);
    expect(p[0].accuracy, closeTo(2 / 3, 1e-9));
    expect(p[1].answered, 0);
    expect(p[1].accuracy, isNull);
  });

  test('câu sai là câu có lần làm gần nhất sai', () {
    final stats = {
      1: stat(1, attempts: 2, correct: 1, last: false),
      2: stat(2, attempts: 2, correct: 1, last: true), // từng sai nhưng đã làm đúng lại
      3: stat(3, attempts: 1, correct: 0, last: false),
    };
    expect(wrongQuestions(bank, stats).map((q) => q.id), [1, 3]);
    expect(wrongQuestions(bank, stats, blockId: 2).map((q) => q.id), [3]);
  });

  test('chưa làm câu nào thì không có câu sai', () {
    expect(wrongQuestions(bank, {}), isEmpty);
  });
}
