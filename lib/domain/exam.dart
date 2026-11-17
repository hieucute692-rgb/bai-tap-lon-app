import 'dart:math';

import 'progress.dart';
import 'question.dart';
import 'question_bank.dart';

/// Bốc [count] câu ngẫu nhiên, số câu mỗi khối tỉ lệ với số câu của khối đó.
List<Question> buildExam(QuestionBank bank, {int count = 30, Random? random}) {
  final rnd = random ?? Random();
  final total = bank.questions.length;
  final n = min(count, total);
  if (n <= 0) return [];

  final groups = <List<Question>>[
    for (final b in bank.blocks) bank.inBlock(b.id)..shuffle(rnd),
  ];

  // Chia hạn ngạch theo phần nguyên, phần dư giao cho các khối có phần lẻ lớn nhất.
  final quotas = <int>[];
  final fractions = <MapEntry<int, double>>[];
  var assigned = 0;
  for (var i = 0; i < groups.length; i++) {
    final exact = n * groups[i].length / total;
    final base = exact.floor();
    quotas.add(base);
    assigned += base;
    fractions.add(MapEntry(i, exact - base));
  }
  fractions.sort((a, b) => b.value.compareTo(a.value));
  for (var k = 0; k < n - assigned; k++) {
    quotas[fractions[k].key]++;
  }

  final picked = <Question>[];
  for (var i = 0; i < groups.length; i++) {
    picked.addAll(groups[i].take(quotas[i]));
  }
  picked.shuffle(rnd);
  return picked;
}

/// Một bài thi thử: làm tự do, đổi đáp án được, chấm khi nộp bài (câu bỏ trống tính sai).
class ExamSession {
  ExamSession(List<Question> questions)
      : questions = List<Question>.unmodifiable(questions);

  final List<Question> questions;
  final Map<int, int> _answers = {};

  int? answerOf(Question q) => _answers[q.id];

  void answer(Question q, int option) {
    if (option < 0 || option > 3) throw RangeError.range(option, 0, 3, 'option');
    _answers[q.id] = option;
  }

  int get answeredCount => questions.where((q) => _answers.containsKey(q.id)).length;
  int get unansweredCount => questions.length - answeredCount;

  bool isCorrect(Question q) => _answers[q.id] == q.correctIndex;
  int get correctCount => questions.where(isCorrect).length;

  /// Mã câu -> đúng/sai, dùng để ghi vào tiến độ.
  Map<int, bool> outcomes() => {for (final q in questions) q.id: isCorrect(q)};

  List<Question> get wrongQuestions =>
      questions.where((q) => !isCorrect(q)).toList(growable: false);

  ExamResult toResult(DateTime at) => ExamResult(
        takenAt: at,
        total: questions.length,
        correct: correctCount,
      );
}
