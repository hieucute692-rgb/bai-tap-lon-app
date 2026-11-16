import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  group('Question.fromJson', () {
    test('đọc đúng các trường', () {
      final q = Question.fromJson(sampleJson(id: 7, blockId: 3, correct: 2));
      expect(q.id, 7);
      expect(q.blockId, 3);
      expect(q.correctIndex, 2);
      expect(q.optionsVi, hasLength(4));
    });

    test('từ chối khi không đủ 4 lựa chọn', () {
      final json = sampleJson()..['options_vi'] = ['A', 'B', 'C'];
      expect(() => Question.fromJson(json), throwsFormatException);
    });

    test('từ chối khi correct_index ngoài 0..3', () {
      expect(
        () => Question.fromJson(sampleJson(correct: 4)),
        throwsFormatException,
      );
    });

    test('chọn nội dung theo ngôn ngữ', () {
      final q = sampleQuestion(id: 5);
      expect(q.questionFor(ContentLanguage.vi), 'Câu hỏi 5');
      expect(q.questionFor(ContentLanguage.en), 'Question 5');
      expect(q.explanationFor(ContentLanguage.en), 'Explanation 5');
    });
  });
}
