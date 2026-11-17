import 'question.dart';
import 'question_bank.dart';

/// Các câu đã đánh dấu, theo thứ tự mã câu. Mã không còn trong ngân hàng bị bỏ qua.
List<Question> bookmarkedQuestions(QuestionBank bank, Set<int> ids) =>
    bank.questions.where((q) => ids.contains(q.id)).toList(growable: false);
