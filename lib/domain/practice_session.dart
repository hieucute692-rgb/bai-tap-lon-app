import 'question.dart';


class PracticeSession {
  PracticeSession(List<Question> questions)
      : questions = List<Question>.unmodifiable(questions),
        assert(questions.isNotEmpty, 'Cần ít nhất một câu hỏi');

  final List<Question> questions;
  final Map<int, int> _chosen = {};
  int index = 0;

  Question get current => questions[index];
  int? get chosen => _chosen[current.id];
  bool get isAnswered => chosen != null;
  bool get isLast => index == questions.length - 1;

  int get correctCount =>
      questions.where((q) => _chosen[q.id] == q.correctIndex).length;

  /// Chọn đáp án cho câu hiện tại. Trả về đúng/sai, hoặc null nếu câu này đã trả lời rồi.
  bool? select(int option) {
    if (option < 0 || option > 3) throw RangeError.range(option, 0, 3, 'option');
    if (isAnswered) return null;
    _chosen[current.id] = option;
    return option == current.correctIndex;
  }

  /// Sang câu tiếp theo; chỉ được khi đã trả lời và chưa phải câu cuối.
  bool next() {
    if (!isAnswered || isLast) return false;
    index++;
    return true;
  }
}
