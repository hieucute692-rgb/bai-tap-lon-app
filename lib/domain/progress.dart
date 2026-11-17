/// Kết quả tích luỹ của một câu hỏi (lưu cục bộ, tối đa 300 bản ghi).
class QuestionStat {
  const QuestionStat({
    required this.questionId,
    required this.attempts,
    required this.correct,
    required this.lastCorrect,
    required this.lastAt,
  });

  factory QuestionStat.fromJson(Map<String, dynamic> json) => QuestionStat(
        questionId: json['id'] as int,
        attempts: json['attempts'] as int,
        correct: json['correct'] as int,
        lastCorrect: json['last_correct'] as bool,
        lastAt: DateTime.parse(json['last_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': questionId,
        'attempts': attempts,
        'correct': correct,
        'last_correct': lastCorrect,
        'last_at': lastAt.toIso8601String(),
      };

  final int questionId;
  final int attempts;
  final int correct;

  /// Lần làm gần nhất đúng hay sai; dùng để xác định "câu sai cần làm lại".
  final bool lastCorrect;
  final DateTime lastAt;

  QuestionStat afterAnswer({required bool isCorrect, required DateTime at}) =>
      QuestionStat(
        questionId: questionId,
        attempts: attempts + 1,
        correct: correct + (isCorrect ? 1 : 0),
        lastCorrect: isCorrect,
        lastAt: at,
      );
}

/// Kết quả một lần thi thử.
class ExamResult {
  const ExamResult({
    required this.takenAt,
    required this.total,
    required this.correct,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
        takenAt: DateTime.parse(json['taken_at'] as String),
        total: json['total'] as int,
        correct: json['correct'] as int,
      );

  Map<String, dynamic> toJson() => {
        'taken_at': takenAt.toIso8601String(),
        'total': total,
        'correct': correct,
      };

  final DateTime takenAt;
  final int total;
  final int correct;

  /// Điểm thang 10.
  double get score10 => total == 0 ? 0 : correct * 10 / total;
}
