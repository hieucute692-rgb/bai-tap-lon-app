import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/exam.dart';
import '../domain/question.dart';
import '../domain/question_text.dart';
import 'settings_controller.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/explanation_card.dart';
import 'widgets/language_toggle.dart';
import 'widgets/question_text.dart';

/// Kết quả thi thử: điểm, và danh sách câu sai kèm đáp án đúng, giải thích.
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key, required this.session, this.timedOut = false});

  final ExamSession session;

  /// Bài được nộp tự động vì hết giờ.
  final bool timedOut;

  String _firstLine(String text) {
    final segments = parseQuestionText(text);
    return segments.isEmpty ? '' : segments.first.content;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final lang = settings.language;
    final s = settings.strings;
    final total = session.questions.length;
    final correct = session.correctCount;
    final wrong = session.wrongQuestions;
    final score = total == 0 ? 0.0 : correct * 10 / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.examResultTitle),
        actions: [
          LanguageToggle(language: lang, onChanged: settings.setLanguage),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.correctOf(correct, total),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(s.scoreOf(score.toStringAsFixed(1))),
          if (timedOut)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(s.timedOutNote),
            ),
          const SizedBox(height: 16),
          if (wrong.isEmpty)
            Text(s.allCorrect)
          else ...[
            Text(
              s.wrongOrUnanswered(wrong.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final q in wrong)
              _WrongTile(
                question: q,
                chosen: session.answerOf(q),
                lang: lang,
                strings: s,
                preview: _firstLine(q.questionFor(lang)),
              ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: Text(s.backToHome),
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
    required this.strings,
    required this.preview,
  });

  final Question question;
  final int? chosen;
  final ContentLanguage lang;
  final AppStrings strings;
  final String preview;

  @override
  Widget build(BuildContext context) {
    final options = question.optionsFor(lang);
    final right = question.correctIndex;
    final pick = chosen;
    return ExpansionTile(
      title: Text(strings.questionLabel(question.id)),
      subtitle: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: BookmarkButton(questionId: question.id),
        ),
        QuestionText(question.questionFor(lang)),
        const SizedBox(height: 8),
        Text(
          pick == null
              ? strings.notAnswered
              : strings.youChose('ABCD'[pick], options[pick]),
        ),
        Text(strings.correctAnswer('ABCD'[right], options[right])),
        ExplanationCard(text: question.explanationFor(lang)),
      ],
    );
  }
}
