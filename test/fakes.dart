import 'dart:async';

import 'package:flutter_quiz_300/domain/progress.dart';
import 'package:flutter_quiz_300/domain/progress_repository.dart';
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
      'options_vi': ['Đáp án A', 'Đáp án B', 'Đáp án C', 'Đáp án D'],
      'options_en': ['Option A', 'Option B', 'Option C', 'Option D'],
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

/// Ngân hàng có [sizes].length khối, khối i có sizes[i] câu; mã câu liên tục từ 1.
QuestionBank bankWithBlockSizes(List<int> sizes) {
  final questions = <Question>[];
  var id = 1;
  for (var b = 0; b < sizes.length; b++) {
    for (var k = 0; k < sizes[b]; k++) {
      questions.add(sampleQuestion(id: id++, blockId: b + 1));
    }
  }
  return QuestionBank(questions);
}

/// Repository câu hỏi giả: kết quả do test điều khiển qua [Completer].
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

/// Repository tiến độ giả lưu trong bộ nhớ, có thể bật lỗi đọc/ghi.
class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({this.failLoad = false, this.failSave = false});

  bool failLoad;
  bool failSave;
  Map<int, QuestionStat> savedStats = {};
  List<ExamResult> savedExams = [];

  @override
  Future<Map<int, QuestionStat>> loadStats() async {
    if (failLoad) throw Exception('lỗi đọc giả lập');
    return Map.of(savedStats);
  }

  @override
  Future<void> saveStats(Map<int, QuestionStat> stats) async {
    if (failSave) throw Exception('lỗi ghi giả lập');
    savedStats = Map.of(stats);
  }

  @override
  Future<List<ExamResult>> loadExamResults() async {
    if (failLoad) throw Exception('lỗi đọc giả lập');
    return List.of(savedExams);
  }

  @override
  Future<void> saveExamResults(List<ExamResult> results) async {
    if (failSave) throw Exception('lỗi ghi giả lập');
    savedExams = List.of(results);
  }
}
