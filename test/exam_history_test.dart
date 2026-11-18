import 'package:flutter/material.dart';
import 'package:flutter_quiz_300/domain/progress.dart';
import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_quiz_300/presentation/bookmark_controller.dart';
import 'package:flutter_quiz_300/presentation/exam_history_detail_screen.dart';
import 'package:flutter_quiz_300/presentation/progress_controller.dart';
import 'package:flutter_quiz_300/presentation/settings_controller.dart';
import 'package:flutter_quiz_300/presentation/stats_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

Widget wrap(ProgressController progress, Widget child, {SettingsController? settings}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressController>.value(value: progress),
        ChangeNotifierProvider<SettingsController>.value(
          value: settings ?? SettingsController(FakeSettingsRepository()),
        ),
        ChangeNotifierProvider<BookmarkController>.value(
          value: BookmarkController(FakeBookmarkRepository()),
        ),
      ],
      child: MaterialApp(home: child),
    );

// Câu 1 đúng, câu 2 chọn sai (C, đáp án đúng là A), câu 3 bỏ trống.
final detailedResult = ExamResult(
  takenAt: DateTime(2026, 1, 2, 9, 30),
  total: 3,
  correct: 1,
  answers: const [
    ExamAnswer(questionId: 1, chosen: 0),
    ExamAnswer(questionId: 2, chosen: 2),
    ExamAnswer(questionId: 3, chosen: null),
  ],
);

final legacyResult = ExamResult(takenAt: DateTime(2026, 1, 1, 8), total: 30, correct: 24);

Future<void> openStats(WidgetTester tester, ExamResult result) async {
  final repo = FakeProgressRepository()
    ..savedStats = {
      1: QuestionStat(
        questionId: 1,
        attempts: 1,
        correct: 1,
        lastCorrect: true,
        lastAt: DateTime(2026, 1, 2),
      ),
    }
    ..savedExams = [result];
  final progress = ProgressController(repo)..load();
  await tester.pumpWidget(wrap(progress, StatsScreen(bank: sampleBank())));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('bấm một lần thi trong lịch sử mở màn xem lại chi tiết', (tester) async {
    await openStats(tester, detailedResult);

    await tester.tap(find.text('1/3 câu · 3.3/10'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết bài thi'), findsOneWidget);
    expect(find.text('Câu 1 · Đúng'), findsOneWidget);
    expect(find.text('Câu 2 · Sai'), findsOneWidget);
    expect(find.text('Câu 3 · Bỏ trống'), findsOneWidget);
  });

  testWidgets('lọc chỉ các câu sai hoặc bỏ trống', (tester) async {
    await openStats(tester, detailedResult);
    await tester.tap(find.text('1/3 câu · 3.3/10'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Câu sai'));
    await tester.pumpAndSettle();

    expect(find.text('Câu 1 · Đúng'), findsNothing);
    expect(find.text('Câu 2 · Sai'), findsOneWidget);
    expect(find.text('Câu 3 · Bỏ trống'), findsOneWidget);
  });

  testWidgets('mở một câu thấy đáp án đã chọn, đáp án đúng và giải thích', (tester) async {
    await openStats(tester, detailedResult);
    await tester.tap(find.text('1/3 câu · 3.3/10'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Câu 2 · Sai'));
    await tester.pumpAndSettle();

    expect(find.text('Bạn chọn: C. Đáp án C'), findsOneWidget);
    expect(find.text('Đáp án đúng: A. Đáp án A'), findsOneWidget);
    expect(find.text('Giải thích 2'), findsOneWidget);
  });

  testWidgets('câu bỏ trống hiện thông báo chưa trả lời', (tester) async {
    await openStats(tester, detailedResult);
    await tester.tap(find.text('1/3 câu · 3.3/10'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Câu 3 · Bỏ trống'));
    await tester.pumpAndSettle();

    expect(find.text('Bạn chưa trả lời.'), findsOneWidget);
  });

  testWidgets('bài thi lưu bởi bản cũ: báo không có chi tiết và có lối ra', (tester) async {
    await openStats(tester, legacyResult);

    await tester.tap(find.text('24/30 câu · 8.0/10'));
    await tester.pumpAndSettle();

    expect(
      find.text('Không có chi tiết cho bài thi này (bài được lưu bởi phiên bản cũ của app).'),
      findsOneWidget,
    );
    await tester.tap(find.text('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết bài thi'), findsNothing);
  });

  testWidgets('màn xem lại hiển thị bằng tiếng Anh khi chọn English', (tester) async {
    final settings = SettingsController(FakeSettingsRepository());
    settings.setLanguage(ContentLanguage.en);
    final progress = ProgressController(FakeProgressRepository());
    await tester.pumpWidget(
      wrap(
        progress,
        ExamHistoryDetailScreen(bank: sampleBank(), result: detailedResult),
        settings: settings,
      ),
    );

    expect(find.text('Exam details'), findsOneWidget);
    expect(find.text('Question 1 · Correct'), findsOneWidget);
    expect(find.text('Question 2 · Wrong'), findsOneWidget);
    expect(find.text('Question 3 · Unanswered'), findsOneWidget);
  });
}
