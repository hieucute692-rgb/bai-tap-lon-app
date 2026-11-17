import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/exam.dart';
import '../domain/question.dart';
import 'exam_result_screen.dart';
import 'progress_controller.dart';
import 'widgets/language_toggle.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Làm bài thi thử: chọn/đổi đáp án tự do, không hiện đúng sai cho tới khi nộp bài.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, required this.questions});

  final List<Question> questions;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final ExamSession _session = ExamSession(widget.questions);
  ContentLanguage _lang = ContentLanguage.vi;
  int _index = 0;

  Future<void> _submit() async {
    final unanswered = _session.unansweredCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nộp bài?'),
        content: Text(
          unanswered == 0
              ? 'Bạn đã trả lời hết các câu.'
              : 'Còn $unanswered câu chưa trả lời, sẽ tính là sai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Làm tiếp'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final progress = context.read<ProgressController>();
    progress.recordAnswers(_session.outcomes());
    progress.addExamResult(_session.toResult(DateTime.now()));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ExamResultScreen(session: _session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _session.questions.length;
    final q = _session.questions[_index];
    final options = q.optionsFor(_lang);
    final selected = _session.answerOf(q);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thi thử · ${_session.answeredCount}/$total đã trả lời'),
        actions: [
          LanguageToggle(language: _lang, onChanged: (l) => setState(() => _lang = l)),
          TextButton(onPressed: _submit, child: const Text('Nộp bài')),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / total,
            semanticsLabel: 'Vị trí câu hỏi',
          ),
          Expanded(
            child: ListView(
              key: ValueKey(_index),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Câu ${_index + 1}/$total',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                QuestionText(q.questionFor(_lang)),
                const SizedBox(height: 12),
                for (var i = 0; i < options.length; i++)
                  OptionTile(
                    letter: 'ABCD'[i],
                    text: options[i],
                    state: selected == i ? OptionState.selected : OptionState.idle,
                    onTap: () => setState(() => _session.answer(q, i)),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                      child: const Text('Câu trước'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _index == total - 1 ? null : () => setState(() => _index++),
                      child: const Text('Câu tiếp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
