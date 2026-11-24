import 'package:flutter_quiz_300/data/asset_question_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  
  const expectedCounts = [20, 22, 25, 15, 18, 15, 18, 9, 20, 9, 9, 20, 23, 12, 9, 20, 8, 8, 12, 8];

  test('nạp đủ 300 câu hợp lệ từ assets', () async {
    final bank = await AssetQuestionRepository().load();
    expect(bank.questions, hasLength(300));
    expect(bank.questions.map((q) => q.id), List.generate(300, (i) => i + 1));
    for (final q in bank.questions) {
      expect(q.optionsVi, hasLength(4), reason: 'câu ${q.id}');
      expect(q.optionsEn, hasLength(4), reason: 'câu ${q.id}');
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: 'câu ${q.id}');
    }
  });

  test('có 20 khối với đúng số câu', () async {
    final bank = await AssetQuestionRepository().load();
    expect(bank.blocks.map((b) => b.id), List.generate(20, (i) => i + 1));
    expect(bank.blocks.map((b) => b.questionCount), expectedCounts);
  });
}
