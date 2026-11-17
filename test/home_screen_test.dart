import 'package:flutter/material.dart';
import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_quiz_300/domain/question_bank.dart';
import 'package:flutter_quiz_300/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<ControlledRepository> pumpApp(
  WidgetTester tester, {
  FakeSettingsRepository? settings,
}) async {
  final repo = ControlledRepository();
  await tester.pumpWidget(
    QuizApp(
      repository: repo,
      progressRepository: FakeProgressRepository(),
      settingsRepository: settings ?? FakeSettingsRepository(),
    ),
  );
  return repo;
}

void main() {
  testWidgets('đang tải rồi hiện menu chức năng', (tester) async {
    final repo = await pumpApp(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repo.completeLast(sampleBank());
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('3 câu · 2 khối kiến thức'), findsOneWidget);
    expect(find.text('Luyện tập'), findsOneWidget);
    expect(find.text('Thi thử'), findsOneWidget);
    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('Làm lại câu sai'), findsOneWidget);
  });

  testWidgets('lỗi có nút Thử lại dẫn tới menu', (tester) async {
    final repo = await pumpApp(tester);
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

    expect(find.text('Luyện tập'), findsOneWidget);
  });

  testWidgets('chưa có dữ liệu hiện trạng thái trống có nút Tải lại', (tester) async {
    final repo = await pumpApp(tester);
    repo.completeLast(QuestionBank(const []));
    await tester.pump();
    await tester.pump();

    expect(find.text('Chưa có câu hỏi nào.'), findsOneWidget);
    expect(find.text('Tải lại'), findsOneWidget);
  });

  testWidgets('chưa có câu sai: báo bằng thông báo, không mở màn hình', (tester) async {
    final repo = await pumpApp(tester);
    repo.completeLast(sampleBank());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Làm lại câu sai'));
    await tester.pump();

    expect(
      find.text('Chưa có câu sai nào. Hãy luyện tập hoặc thi thử trước.'),
      findsOneWidget,
    );
  });

  testWidgets('chọn English ở trang chủ: lưu lại và áp dụng khi luyện tập', (tester) async {
    final settings = FakeSettingsRepository();
    final repo = await pumpApp(tester, settings: settings);
    repo.completeLast(sampleBank());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('English'));
    await tester.pump();
    expect(settings.saved, ContentLanguage.en);

    await tester.tap(find.text('Luyện tập'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tất cả các khối'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Option A'), findsOneWidget);
  });

  testWidgets('ngôn ngữ đã lưu được khôi phục khi mở app', (tester) async {
    final settings = FakeSettingsRepository(saved: ContentLanguage.en);
    final repo = await pumpApp(tester, settings: settings);
    repo.completeLast(sampleBank());
    await tester.pump();
    await tester.pump();

    final button = tester.widget<SegmentedButton<ContentLanguage>>(
      find.byType(SegmentedButton<ContentLanguage>),
    );
    expect(button.selected, {ContentLanguage.en});
  });
}
