import 'package:flutter_quiz_300/presentation/question_bank_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('nạp thành công chuyển loading -> ready', () async {
    final repo = ControlledRepository();
    final c = QuestionBankController(repo);
    final future = c.load();
    expect(c.status, LoadStatus.loading);
    repo.completeLast(sampleBank());
    await future;
    expect(c.status, LoadStatus.ready);
    expect(c.bank!.questions, hasLength(3));
  });

  test('lỗi chuyển sang error, thử lại thì thành công', () async {
    final repo = ControlledRepository();
    final c = QuestionBankController(repo);
    final first = c.load();
    repo.failLast();
    await first;
    expect(c.status, LoadStatus.error);
    expect(c.errorMessage, isNotNull);

    final retry = c.load();
    expect(c.status, LoadStatus.loading);
    repo.completeLast(sampleBank());
    await retry;
    expect(c.status, LoadStatus.ready);
    expect(c.errorMessage, isNull);
  });

  test('dispose giữa lúc đang nạp không gây lỗi', () async {
    final repo = ControlledRepository();
    final c = QuestionBankController(repo);
    final future = c.load();
    c.dispose();
    repo.completeLast(sampleBank());
    await future; // không được ném lỗi
  });
}
