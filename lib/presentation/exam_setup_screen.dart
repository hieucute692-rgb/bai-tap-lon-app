import 'package:flutter/material.dart';

import '../domain/exam.dart';
import '../domain/exam_countdown.dart';
import '../domain/question_bank.dart';
import 'exam_screen.dart';

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
    final total = widget.bank.questions.length;
    var options = [10, 20, 30].where((n) => n <= total).toList();
    if (options.isEmpty) options = [total];
    final count = _picked ?? options.last;

    return Scaffold(
      appBar: AppBar(title: const Text('Thi thử')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Số câu', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              for (final n in options)
                ButtonSegment<int>(value: n, label: Text('$n câu')),
            ],
            selected: {count},
            onSelectionChanged: (s) => setState(() => _picked = s.first),
          ),
          const SizedBox(height: 8),
          Text('Thời gian làm bài: ${defaultExamDuration(count).inMinutes} phút'),
          const SizedBox(height: 16),
          const Text(
            'Câu hỏi được bốc ngẫu nhiên, số câu mỗi khối tỉ lệ với số câu của khối đó. '
            'Đáp án chỉ hiện sau khi nộp bài; câu bỏ trống tính là sai. '
            'Hết giờ, bài được nộp tự động.',
          ),
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
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }
}
