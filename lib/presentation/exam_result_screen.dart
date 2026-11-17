import 'package:flutter/material.dart';

import '../domain/exam.dart';
import '../domain/question.dart';
import '../domain/question_text.dart';
import 'widgets/explanation_card.dart';
import 'widgets/language_toggle.dart';
import 'widgets/question_text.dart';

/// Kết quả thi thử: điểm, và danh sách câu sai kèm đáp án đúng, giải thích.
class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({super.key, required this.session});

  final ExamSession session;

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  ContentLanguage _lang = ContentLanguage.vi;

  String _firstLine(String text) {
    final segments = parseQuestionText(text);
    return segments.isEmpty ? '' : segments.first.content;
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final total = session.questions.length;
    final correct = session.correctCount;
    final wrong = session.wrongQuestions;
    final score = total == 0 ? 0.0 : correct * 10 / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả thi thử'),
        actions: [
          LanguageToggle(language: _lang, onChanged: (l) => setState(() => _lang = l)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Đúng $correct/$total câu',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('Điểm: ${score.toStringAsFixed(1)}/10'),
          const SizedBox(height: 16),
          if (wrong.isEmpty)
            const Text('Bạn trả lời đúng tất cả các câu.')
          else ...[
            Text(
              'Các câu sai hoặc bỏ trống (${wrong.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final q in wrong) _WrongTile(
              question: q,
              chosen: session.answerOf(q),
              lang: _lang,
              preview: _firstLine(q.questionFor(_lang)),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }
}

class _WrongTile extends StatelessWidget {
  const _WrongTile({
    required this.question,
    required this.chosen,
    required this.lang,
    required this.preview,
  });

  final Question question;
  final int? chosen;
  final ContentLanguage lang;
  final String preview;

  @override
  Widget build(BuildContext context) {
    final options = question.optionsFor(lang);
    final right = question.correctIndex;
    return ExpansionTile(
      title: Text('Câu ${question.id}'),
      subtitle: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionText(question.questionFor(lang)),
        const SizedBox(height: 8),
        Text(
          chosen == null
              ? 'Bạn chưa trả lời.'
              : 'Bạn chọn: ${'ABCD'[chosen!]}. ${options[chosen!]}',
        ),
        Text('Đáp án đúng: ${'ABCD'[right]}. ${options[right]}'),
        ExplanationCard(text: question.explanationFor(lang)),
      ],
    );
  }
}
