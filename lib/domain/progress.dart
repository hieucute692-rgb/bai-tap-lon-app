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

/// Đáp án người dùng đã chọn cho một câu trong một lần thi thử (null = bỏ trống).
class ExamAnswer {
  const ExamAnswer({required this.questionId, required this.chosen});

  factory ExamAnswer.fromJson(Map<String, dynamic> json) => ExamAnswer(
        questionId: json['id'] as int,
        chosen: json['c'] as int?,
      );

  Map<String, dynamic> toJson() => {'id': questionId, 'c': chosen};

  final int questionId;
  final int? chosen;
}

/// Kết quả một lần thi thử, kèm đáp án đã chọn từng câu để xem lại chi tiết.
class ExamResult {
  const ExamResult({
    required this.takenAt,
    required this.total,
    required this.correct,
    this.answers = const [],
  });

  /// Bản lưu từ phiên bản cũ không có "answers": đọc được nhưng không xem lại chi tiết được.
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final raw = json['answers'];
    return ExamResult(
      takenAt: DateTime.parse(json['taken_at'] as String),
      total: json['total'] as int,
      correct: json['correct'] as int,
      answers: raw is List
          ? raw.map((e) => ExamAnswer.fromJson(e as Map<String, dynamic>)).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'taken_at': takenAt.toIso8601String(),
        'total': total,
        'correct': correct,
        'answers': answers.map((a) => a.toJson()).toList(),
      };

  final DateTime takenAt;
  final int total;
  final int correct;

  /// Đáp án từng câu theo thứ tự trong bài thi; rỗng nếu bản lưu cũ.
  final List<ExamAnswer> answers;

  bool get hasDetails => answers.isNotEmpty;

  /// Điểm thang 10.
  double get score10 => total == 0 ? 0 : correct * 10 / total;
}
