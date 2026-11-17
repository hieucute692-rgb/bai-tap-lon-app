import 'dart:math';

import 'package:flutter_quiz_300/domain/exam.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  group('buildExam', () {
    test('chia theo tỉ lệ số câu của khối', () {
      final bank = bankWithBlockSizes([10, 20, 30]);
      final exam = buildExam(bank, count: 30, random: Random(1));
      expect(exam, hasLength(30));
      int inBlock(int b) => exam.where((q) => q.blockId == b).length;
      expect([inBlock(1), inBlock(2), inBlock(3)], [5, 10, 15]);
    });

    test('không trùng câu', () {
      final bank = bankWithBlockSizes([10, 20, 30]);
      final exam = buildExam(bank, count: 30, random: Random(2));
      expect(exam.map((q) => q.id).toSet(), hasLength(30));
    });

    test('phần dư được chia cho các khối, tổng đúng số câu', () {
      final bank = bankWithBlockSizes([7, 7, 7]);
      final exam = buildExam(bank, count: 10, random: Random(3));
      expect(exam, hasLength(10));
      for (final b in [1, 2, 3]) {
        final n = exam.where((q) => q.blockId == b).length;
        expect(n, inInclusiveRange(3, 4));
      }
    });

    test('xin nhiều hơn tổng số câu thì lấy tất cả', () {
      final bank = bankWithBlockSizes([2, 3]);
      expect(buildExam(bank, count: 30), hasLength(5));
    });
  });

  group('ExamSession', () {
    test('câu bỏ trống tính sai', () {
      final bank = bankWithBlockSizes([3]);
      final s = ExamSession(bank.questions);
      s.answer(bank.questions[0], 0); // đúng (correct_index = 0)
      s.answer(bank.questions[1], 2); // sai
      expect(s.answeredCount, 2);
      expect(s.unansweredCount, 1);
      expect(s.correctCount, 1);
      expect(s.wrongQuestions.map((q) => q.id), [2, 3]);
    });

    test('được đổi đáp án trước khi nộp', () {
      final bank = bankWithBlockSizes([1]);
      final s = ExamSession(bank.questions);
      s.answer(bank.questions[0], 3);
      s.answer(bank.questions[0], 0);
      expect(s.correctCount, 1);
    });

    test('outcomes và toResult phản ánh kết quả chấm', () {
      final bank = bankWithBlockSizes([2]);
      final s = ExamSession(bank.questions);
      s.answer(bank.questions[0], 0);
      expect(s.outcomes(), {1: true, 2: false});
      final r = s.toResult(DateTime(2026, 1, 1));
      expect(r.total, 2);
      expect(r.correct, 1);
      expect(r.score10, 5);
    });

    test('từ chối lựa chọn ngoài 0..3', () {
      final bank = bankWithBlockSizes([1]);
      final s = ExamSession(bank.questions);
      expect(() => s.answer(bank.questions[0], 4), throwsRangeError);
    });
  });
}
