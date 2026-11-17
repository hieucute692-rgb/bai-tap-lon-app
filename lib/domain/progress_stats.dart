import 'progress.dart';
import 'question.dart';
import 'question_bank.dart';

/// Thống kê của một khối kiến thức.
class BlockProgress {
  const BlockProgress({
    required this.block,
    required this.answered,
    required this.attempts,
    required this.correct,
    required this.wrong,
  });

  final QuestionBlock block;

  /// Số câu đã làm ít nhất một lần.
  final int answered;

  /// Tổng số lượt làm và số lượt đúng.
  final int attempts;
  final int correct;

  /// Số câu mà lần làm gần nhất là sai.
  final int wrong;

  int get total => block.questionCount;
  double? get accuracy => attempts == 0 ? null : correct / attempts;
}

List<BlockProgress> computeBlockProgress(
  QuestionBank bank,
  Map<int, QuestionStat> stats,
) {
  final answered = <int, int>{};
  final attempts = <int, int>{};
  final correct = <int, int>{};
  final wrong = <int, int>{};
  for (final q in bank.questions) {
    final s = stats[q.id];
    if (s == null || s.attempts == 0) continue;
    answered[q.blockId] = (answered[q.blockId] ?? 0) + 1;
    attempts[q.blockId] = (attempts[q.blockId] ?? 0) + s.attempts;
    correct[q.blockId] = (correct[q.blockId] ?? 0) + s.correct;
    if (!s.lastCorrect) wrong[q.blockId] = (wrong[q.blockId] ?? 0) + 1;
  }
  return [
    for (final b in bank.blocks)
      BlockProgress(
        block: b,
        answered: answered[b.id] ?? 0,
        attempts: attempts[b.id] ?? 0,
        correct: correct[b.id] ?? 0,
        wrong: wrong[b.id] ?? 0,
      ),
  ];
}

/// Các câu mà lần làm gần nhất là sai (tuỳ chọn lọc theo khối).
List<Question> wrongQuestions(
  QuestionBank bank,
  Map<int, QuestionStat> stats, {
  int? blockId,
}) {
  return bank.questions.where((q) {
    if (blockId != null && q.blockId != blockId) return false;
    final s = stats[q.id];
    return s != null && !s.lastCorrect;
  }).toList(growable: false);
}
