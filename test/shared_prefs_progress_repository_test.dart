import 'package:flutter_quiz_300/data/shared_prefs_progress_repository.dart';
import 'package:flutter_quiz_300/domain/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('lưu rồi đọc lại đúng tiến độ và lịch sử thi', () async {
    final repo = SharedPrefsProgressRepository();
    final at = DateTime(2026, 1, 2, 3, 4);
    await repo.saveStats({
      5: QuestionStat(questionId: 5, attempts: 3, correct: 2, lastCorrect: false, lastAt: at),
    });
    await repo.saveExamResults([ExamResult(takenAt: at, total: 30, correct: 24)]);

    final stats = await SharedPrefsProgressRepository().loadStats();
    expect(stats[5]!.attempts, 3);
    expect(stats[5]!.lastCorrect, isFalse);
    expect(stats[5]!.lastAt, at);

    final exams = await SharedPrefsProgressRepository().loadExamResults();
    expect(exams.single.correct, 24);
  });

  test('chưa có dữ liệu thì trả về rỗng', () async {
    final repo = SharedPrefsProgressRepository();
    expect(await repo.loadStats(), isEmpty);
    expect(await repo.loadExamResults(), isEmpty);
  });

  test('dữ liệu hỏng không làm app dừng, trả về rỗng', () async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsProgressRepository.statsKey: '{không phải json',
      SharedPrefsProgressRepository.examsKey: '[1, 2, 3]',
    });
    final repo = SharedPrefsProgressRepository();
    expect(await repo.loadStats(), isEmpty);
    expect(await repo.loadExamResults(), isEmpty);
  });
}
