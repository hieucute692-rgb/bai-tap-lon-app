import 'package:flutter/material.dart';
import 'package:flutter_quiz_300/domain/question_bank.dart';
import 'package:flutter_quiz_300/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('đang tải rồi hiện danh sách khối', (tester) async {
    final repo = ControlledRepository();
    await tester.pumpWidget(QuizApp(repository: repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repo.completeLast(sampleBank());
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('3 câu · 2 khối kiến thức'), findsOneWidget);
    expect(find.text('Khối 1'), findsOneWidget);
  });

  testWidgets('lỗi có nút Thử lại dẫn tới danh sách', (tester) async {
    final repo = ControlledRepository();
    await tester.pumpWidget(QuizApp(repository: repo));
    repo.failLast();
    await tester.pump();
    await tester.pump();

    expect(find.text('Không tải được ngân hàng câu hỏi.'), findsOneWidget);

    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    expect(repo.callCount, 2);
    repo.completeLast(sampleBank());
    await tester.pump();
    await tester.pump();

    expect(find.text('Khối 1'), findsOneWidget);
  });

  testWidgets('chưa có dữ liệu hiện trạng thái trống có nút Tải lại', (tester) async {
    final repo = ControlledRepository();
    await tester.pumpWidget(QuizApp(repository: repo));
    repo.completeLast(QuestionBank(const []));
    await tester.pump();
    await tester.pump();

    expect(find.text('Chưa có câu hỏi nào.'), findsOneWidget);
    expect(find.text('Tải lại'), findsOneWidget);
  });
}
