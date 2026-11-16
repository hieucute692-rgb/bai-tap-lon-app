import 'dart:async';

import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_quiz_300/domain/question_bank.dart';
import 'package:flutter_quiz_300/domain/question_repository.dart';

Map<String, dynamic> sampleJson({int id = 1, int blockId = 1, int correct = 0}) => {
      'id': id,
      'block_id': blockId,
      'block_name_vi': 'Khối $blockId',
      'block_name_en': 'Block $blockId',
      'question_vi': 'Câu hỏi $id',
      'question_en': 'Question $id',
      'options_vi': ['A', 'B', 'C', 'D'],
      'options_en': ['A', 'B', 'C', 'D'],
      'correct_index': correct,
      'explanation_vi': 'Giải thích $id',
      'explanation_en': 'Explanation $id',
    };

Question sampleQuestion({int id = 1, int blockId = 1}) =>
    Question.fromJson(sampleJson(id: id, blockId: blockId));

QuestionBank sampleBank() => QuestionBank([
      sampleQuestion(id: 1, blockId: 1),
      sampleQuestion(id: 2, blockId: 1),
      sampleQuestion(id: 3, blockId: 2),
    ]);

/// Repository giả: kết quả do test điều khiển qua [Completer].
class ControlledRepository implements QuestionRepository {
  final List<Completer<QuestionBank>> _pending = [];

  int get callCount => _pending.length;

  @override
  Future<QuestionBank> load() {
    final c = Completer<QuestionBank>();
    _pending.add(c);
    return c.future;
  }

  void completeLast(QuestionBank bank) => _pending.last.complete(bank);
  void failLast() => _pending.last.completeError(Exception('lỗi giả lập'));
}
