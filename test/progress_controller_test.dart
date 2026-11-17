import 'package:flutter_quiz_300/domain/progress.dart';
import 'package:flutter_quiz_300/presentation/progress_controller.dart';
import 'package:flutter_quiz_300/presentation/question_bank_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  DateTime clock() => DateTime(2026, 1, 1);

  test('ghi nhận lượt làm đầu tiên và lưu xuống repository', () async {
    final repo = FakeProgressRepository();
    final c = ProgressController(repo, clock: clock);
    await c.recordAnswers({1: true});
    expect(c.stats[1]!.attempts, 1);
    expect(c.stats[1]!.correct, 1);
    expect(repo.savedStats[1]!.lastCorrect, isTrue);
  });

  test('làm lại: cộng dồn lượt, lần gần nhất quyết định đúng/sai', () async {
    final c = ProgressController(FakeProgressRepository(), clock: clock);
    await c.recordAnswers({1: true});
    await c.recordAnswers({1: false});
    expect(c.stats[1]!.attempts, 2);
    expect(c.stats[1]!.correct, 1);
    expect(c.stats[1]!.lastCorrect, isFalse);
  });

  test('lỗi ghi: vẫn giữ trong bộ nhớ và báo problem', () async {
    final c = ProgressController(FakeProgressRepository(failSave: true), clock: clock);
    await c.recordAnswers({1: true});
    expect(c.stats[1], isNotNull);
    expect(c.problem, isNotNull);
  });

  test('lỗi đọc: bắt đầu từ rỗng, báo problem, app vẫn sẵn sàng', () async {
    final c = ProgressController(FakeProgressRepository(failLoad: true));
    await c.load();
    expect(c.status, LoadStatus.ready);
    expect(c.stats, isEmpty);
    expect(c.problem, isNotNull);
  });

  test('chỉ giữ tối đa 20 lần thi gần nhất, mới nhất ở đầu', () async {
    final c = ProgressController(FakeProgressRepository());
    for (var i = 1; i <= 25; i++) {
      await c.addExamResult(ExamResult(takenAt: DateTime(2026, 1, i), total: 30, correct: i));
    }
    expect(c.examResults, hasLength(ProgressController.maxExamHistory));
    expect(c.examResults.first.correct, 25);
  });
}
