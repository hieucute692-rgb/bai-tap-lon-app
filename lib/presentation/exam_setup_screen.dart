import 'package:flutter/material.dart';

import '../domain/exam.dart';
import '../domain/exam_countdown.dart';
import '../domain/question_bank.dart';
import 'exam_screen.dart';
import 'strings_context.dart';

/// Chọn số câu cho bài thi thử rồi bắt đầu.
class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({super.key, required this.bank});

  final QuestionBank bank;

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final total = widget.bank.questions.length;
    var options = [10, 20, 30].where((n) => n <= total).toList();
    if (options.isEmpty) options = [total];
    final count = _picked ?? options.last;

    return Scaffold(
      appBar: AppBar(title: Text(s.exam)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.questionCountLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              for (final n in options)
                ButtonSegment<int>(value: n, label: Text(s.questionCount(n))),
            ],
            selected: {count},
            onSelectionChanged: (sel) => setState(() => _picked = sel.first),
          ),
          const SizedBox(height: 8),
          Text(s.timeLimit(defaultExamDuration(count).inMinutes)),
          const SizedBox(height: 16),
          Text(s.examRules),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              final questions = buildExam(widget.bank, count: count);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ExamScreen(
                    questions: questions,
                    duration: defaultExamDuration(questions.length),
                  ),
                ),
              );
            },
            child: Text(s.start),
          ),
        ],
      ),
    );
  }
}
