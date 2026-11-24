import 'question_bank.dart';


abstract class QuestionRepository {
  Future<QuestionBank> load();
}
