import 'package:flutter/material.dart';
import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_quiz_300/presentation/exam_screen.dart';
import 'package:flutter_quiz_300/presentation/practice_screen.dart';
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
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('luyện tập: chọn sai hiện giải thích và ghi nhận kết quả sai', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    await tester.pumpWidget(
      wrap(progress, PracticeScreen(titleOf: (_) => 'Thử', questions: [sampleQuestion(id: 1)])),
    );

    expect(find.text('Giải thích 1'), findsNothing);
    await tester.tap(find.text('Đáp án B')); // đáp án đúng là A
    await tester.pump();

    expect(find.text('Giải thích 1'), findsOneWidget);
    expect(progress.stats[1]!.lastCorrect, isFalse);
  });

  testWidgets('luyện tập: đổi ngôn ngữ trong lúc làm đổi cả giao diện lẫn cài đặt chung', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    final settingsRepo = FakeSettingsRepository();
    final settings = SettingsController(settingsRepo);
    await tester.pumpWidget(
      wrap(
        progress,
        PracticeScreen(titleOf: (_) => 'Thử', questions: [sampleQuestion(id: 1)]),
        settings: settings,
      ),
    );

    expect(find.text('Câu hỏi 1'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pump();

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget); // chữ trên giao diện cũng đổi
    expect(find.text('Hoàn tất'), findsNothing);
    expect(settings.language, ContentLanguage.en);
    expect(settingsRepo.saved, ContentLanguage.en);
  });

  testWidgets('luyện tập: làm xong hiện tổng kết', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    await tester.pumpWidget(
      wrap(progress, PracticeScreen(titleOf: (_) => 'Thử', questions: [sampleQuestion(id: 1)])),
    );

    await tester.tap(find.text('Đáp án A'));
    await tester.pump();
    await tester.tap(find.text('Hoàn tất'));
    await tester.pump();

    expect(find.text('Đúng 1/1 câu'), findsOneWidget);
  });

  // Lưu ý: khi đồng hồ đang chạy, tránh pumpAndSettle vì Timer 1 giây liên tục xin vẽ lại.
  group('thi thử có đồng hồ', () {
    late DateTime now;
    late ProgressController progress;
    final questions = [sampleQuestion(id: 1), sampleQuestion(id: 2)];

    Future<void> openExam(WidgetTester tester) async {
      now = DateTime(2026, 1, 1, 8);
      progress = ProgressController(FakeProgressRepository());
      await tester.pumpWidget(
        wrap(
          progress,
          ExamScreen(
            questions: questions,
            duration: const Duration(minutes: 3),
            clock: () => now,
          ),
        ),
      );
    }

    testWidgets('hiện thời gian còn lại và giảm theo từng giây', (tester) async {
      await openExam(tester);
      expect(find.text('Còn lại 03:00'), findsOneWidget);

      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Còn lại 02:59'), findsOneWidget);
    });

    testWidgets('nộp bài có xác nhận, chấm và lưu kết quả', (tester) async {
      await openExam(tester);

      await tester.tap(find.text('Đáp án A')); // câu 1 đúng; câu 2 bỏ trống
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, 'Nộp bài'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Còn 1 câu chưa trả lời, sẽ tính là sai.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Nộp bài'));
      await tester.pumpAndSettle(); // đồng hồ đã dừng nên chờ được

      expect(find.text('Đúng 1/2 câu'), findsOneWidget);
      expect(find.text('Hết giờ, bài đã được nộp tự động.'), findsNothing);
      expect(progress.examResults, hasLength(1));
      expect(progress.stats[2]!.lastCorrect, isFalse);
    });

    testWidgets('hết giờ thì tự nộp và báo trên màn kết quả', (tester) async {
      await openExam(tester);
      await tester.tap(find.text('Đáp án A'));
      await tester.pump();

      now = now.add(const Duration(minutes: 3, seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Hết giờ, bài đã được nộp tự động.'), findsOneWidget);
      expect(find.text('Đúng 1/2 câu'), findsOneWidget);
      expect(progress.examResults, hasLength(1));
    });

    testWidgets('hết giờ khi hộp xác nhận đang mở: đóng hộp và nộp một lần', (tester) async {
      await openExam(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Nộp bài'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Nộp bài?'), findsOneWidget);

      now = now.add(const Duration(minutes: 3, seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Nộp bài?'), findsNothing);
      expect(find.text('Hết giờ, bài đã được nộp tự động.'), findsOneWidget);
      expect(progress.examResults, hasLength(1));
    });
  });

  testWidgets('thống kê: chưa làm câu nào hiện trạng thái trống có lối ra', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    progress.load();
    await tester.pumpWidget(wrap(progress, StatsScreen(bank: sampleBank())));
    await tester.pump();
    await tester.pump();

    expect(find.text('Bạn chưa làm câu nào.'), findsOneWidget);
    expect(find.text('Quay lại để bắt đầu'), findsOneWidget);
  });

  testWidgets('thống kê: hiện tỉ lệ đúng theo khối sau khi làm bài', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    progress.load();
    await tester.pumpWidget(wrap(progress, StatsScreen(bank: sampleBank())));
    await tester.pump();
    await tester.pump();
    progress.recordAnswers({1: true, 2: false});
    await tester.pump();

    expect(find.text('Đã làm 2/3 câu'), findsOneWidget);
    expect(find.text('Khối 1. Khối 1'), findsOneWidget);
  });
}
