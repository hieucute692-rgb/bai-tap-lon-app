import 'question.dart';


class QuestionBlock {
  const QuestionBlock({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.questionCount,
  });

  final int id;
  final String nameVi;
  final String nameEn;
  final int questionCount;

  String nameFor(ContentLanguage lang) =>
      lang == ContentLanguage.vi ? nameVi : nameEn;
}

/// Toàn bộ ngân hàng câu hỏi đã nạp, kèm danh sách khối suy ra từ dữ liệu.
class QuestionBank {
  QuestionBank._(this.questions, this.blocks);

  factory QuestionBank(List<Question> questions) {
    final list = List<Question>.unmodifiable(questions);
    final counts = <int, int>{};
    final firstOfBlock = <int, Question>{};
    for (final q in list) {
      counts[q.blockId] = (counts[q.blockId] ?? 0) + 1;
      firstOfBlock.putIfAbsent(q.blockId, () => q);
    }
    final ids = firstOfBlock.keys.toList()..sort();
    final blocks = ids
        .map(
          (id) => QuestionBlock(
            id: id,
            nameVi: firstOfBlock[id]!.blockNameVi,
            nameEn: firstOfBlock[id]!.blockNameEn,
            questionCount: counts[id]!,
          ),
        )
        .toList(growable: false);
    return QuestionBank._(list, blocks);
  }

  final List<Question> questions;
  final List<QuestionBlock> blocks;

  bool get isEmpty => questions.isEmpty;

  List<Question> inBlock(int blockId) =>
      questions.where((q) => q.blockId == blockId).toList(growable: false);
}
