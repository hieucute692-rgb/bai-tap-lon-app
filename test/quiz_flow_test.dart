import 'package:flutter/material.dart';
import 'package:flutter_quiz_300/presentation/exam_screen.dart';
import 'package:flutter_quiz_300/presentation/practice_screen.dart';
import 'package:flutter_quiz_300/presentation/progress_controller.dart';
import 'package:flutter_quiz_300/presentation/stats_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

Widget wrap(ProgressController progress, Widget child) =>
    ChangeNotifierProvider<ProgressController>.value(
      value: progress,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('luyện tập: chọn sai hiện giải thích và ghi nhận kết quả sai', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    await tester.pumpWidget(
      wrap(progress, PracticeScreen(title: 'Thử', questions: [sampleQuestion(id: 1)])),
    );

    expect(find.text('Giải thích 1'), findsNothing);
    await tester.tap(find.text('Đáp án B')); // đáp án đúng là A
    await tester.pump();

    expect(find.text('Giải thích 1'), findsOneWidget);
    expect(progress.stats[1]!.lastCorrect, isFalse);
  });

  testWidgets('luyện tập: làm xong hiện tổng kết', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    await tester.pumpWidget(
      wrap(progress, PracticeScreen(title: 'Thử', questions: [sampleQuestion(id: 1)])),
    );

    await tester.tap(find.text('Đáp án A'));
    await tester.pump();
    await tester.tap(find.text('Hoàn tất'));
    await tester.pump();

    expect(find.text('Đúng 1/1 câu'), findsOneWidget);
  });

  testWidgets('thi thử: nộp bài có xác nhận, chấm và lưu kết quả', (tester) async {
    final progress = ProgressController(FakeProgressRepository());
    final questions = [sampleQuestion(id: 1), sampleQuestion(id: 2)];
    await tester.pumpWidget(wrap(progress, ExamScreen(questions: questions)));

    await tester.tap(find.text('Đáp án A')); // câu 1 đúng; câu 2 bỏ trống
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Nộp bài'));
    await tester.pumpAndSettle();
    expect(find.text('Còn 1 câu chưa trả lời, sẽ tính là sai.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Nộp bài'));
    await tester.pumpAndSettle();

    expect(find.text('Đúng 1/2 câu'), findsOneWidget);
    expect(progress.examResults, hasLength(1));
    expect(progress.stats[2]!.lastCorrect, isFalse);
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
