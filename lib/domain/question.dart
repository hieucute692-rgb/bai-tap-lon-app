/// Ngôn ngữ hiển thị nội dung câu hỏi.
enum ContentLanguage { vi, en }

/// Một câu trắc nghiệm song ngữ (khớp với từng phần tử trong questions.json).
class Question {
  const Question({
    required this.id,
    required this.blockId,
    required this.blockNameVi,
    required this.blockNameEn,
    required this.questionVi,
    required this.questionEn,
    required this.optionsVi,
    required this.optionsEn,
    required this.correctIndex,
    required this.explanationVi,
    required this.explanationEn,
  });

  /// Đọc từ JSON và kiểm tra dữ liệu; ném [FormatException] nếu sai cấu trúc.
  factory Question.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw FormatException('Thiếu hoặc sai kiểu "id": $id');
    }

    List<String> readOptions(String key) {
      final raw = json[key];
      if (raw is! List || raw.length != 4) {
        throw FormatException('Câu $id: "$key" phải có đúng 4 lựa chọn');
      }
      return List<String>.unmodifiable(raw.map((e) => e as String));
    }

    final correct = json['correct_index'];
    if (correct is! int || correct < 0 || correct > 3) {
      throw FormatException('Câu $id: "correct_index" phải nằm trong 0..3');
    }

    return Question(
      id: id,
      blockId: json['block_id'] as int,
      blockNameVi: json['block_name_vi'] as String,
      blockNameEn: json['block_name_en'] as String,
      questionVi: json['question_vi'] as String,
      questionEn: json['question_en'] as String,
      optionsVi: readOptions('options_vi'),
      optionsEn: readOptions('options_en'),
      correctIndex: correct,
      explanationVi: json['explanation_vi'] as String,
      explanationEn: json['explanation_en'] as String,
    );
  }

  final int id;
  final int blockId;
  final String blockNameVi;
  final String blockNameEn;
  final String questionVi;
  final String questionEn;
  final List<String> optionsVi;
  final List<String> optionsEn;
  final int correctIndex;
  final String explanationVi;
  final String explanationEn;

  // CRUD và lưu ra file .json
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'block_id': blockId,
    'block_name_vi': blockNameVi,
    'block_name_en': blockNameEn,
    'question_vi': questionVi,
    'question_en': questionEn,
    'options_vi': optionsVi,
    'options_en': optionsEn,
    'correct_index': correctIndex,
    'explanation_vi': explanationVi,
    'explanation_en': explanationEn,
  };

  Question copyWith({
    int? id,
    int? blockId,
    String? blockNameVi,
    String? blockNameEn,
    String? questionVi,
    String? questionEn,
    List<String>? optionsVi,
    List<String>? optionsEn,
    int? correctIndex,
    String? explanationVi,
    String? explanationEn,
  }) {
    return Question(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      blockNameVi: blockNameVi ?? this.blockNameVi,
      blockNameEn: blockNameEn ?? this.blockNameEn,
      questionVi: questionVi ?? this.questionVi,
      questionEn: questionEn ?? this.questionEn,
      optionsVi: optionsVi ?? this.optionsVi,
      optionsEn: optionsEn ?? this.optionsEn,
      correctIndex: correctIndex ?? this.correctIndex,
      explanationVi: explanationVi ?? this.explanationVi,
      explanationEn: explanationEn ?? this.explanationEn,
    );
  }

  String blockNameFor(ContentLanguage lang) =>
      lang == ContentLanguage.vi ? blockNameVi : blockNameEn;

  String questionFor(ContentLanguage lang) =>
      lang == ContentLanguage.vi ? questionVi : questionEn;

  List<String> optionsFor(ContentLanguage lang) =>
      lang == ContentLanguage.vi ? optionsVi : optionsEn;

  String explanationFor(ContentLanguage lang) =>
      lang == ContentLanguage.vi ? explanationVi : explanationEn;
}
