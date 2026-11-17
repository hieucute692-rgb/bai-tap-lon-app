import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/practice_session.dart';
import '../domain/question.dart';
import 'progress_controller.dart';
import 'settings_controller.dart';
import 'strings_context.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/explanation_card.dart';
import 'widgets/language_toggle.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Tiêu đề màn hình, tính lại mỗi lần vẽ để đổi theo ngôn ngữ đang chọn.
typedef PracticeTitle = String Function(AppStrings strings);

/// Luyện tập: chọn đáp án là biết đúng sai ngay, kèm giải thích.
/// Dùng chung cho luyện theo khối và "làm lại câu sai".
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.titleOf, required this.questions});

  final PracticeTitle titleOf;
  final List<Question> questions;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeSession _session = PracticeSession(widget.questions);
  bool _finished = false;

  void _select(int option) {
    final isCorrect = _session.select(option);
    if (isCorrect == null) return;
    setState(() {});
    context.read<ProgressController>().recordAnswers({_session.current.id: isCorrect});
  }

  void _next() {
    setState(() {
      if (_session.isLast) {
        _finished = true;
      } else {
        _session.next();
      }
    });
  }

  OptionState _stateOf(int i, Question q, int? chosen) {
    if (chosen == null) return OptionState.idle;
    if (i == q.correctIndex) return OptionState.correct;
    if (i == chosen) return OptionState.wrong;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final lang = settings.language;
    final s = settings.strings;
    if (_finished) {
      return _PracticeSummary(
        correct: _session.correctCount,
        total: _session.questions.length,
      );
    }
    final q = _session.current;
    final chosen = _session.chosen;
    final options = q.optionsFor(lang);
    final total = _session.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleOf(s)),
        actions: [
          LanguageToggle(language: lang, onChanged: settings.setLanguage),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_session.index + 1) / total,
            semanticsLabel: s.practiceProgress,
          ),
          Expanded(
            child: ListView(
              key: ValueKey(_session.index),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.practiceQuestionHeader(_session.index + 1, total, q.blockId),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    BookmarkButton(questionId: q.id),
                  ],
                ),
                QuestionText(q.questionFor(lang)),
                const SizedBox(height: 12),
                for (var i = 0; i < options.length; i++)
                  OptionTile(
                    letter: 'ABCD'[i],
                    text: options[i],
                    state: _stateOf(i, q, chosen),
                    onTap: chosen == null ? () => _select(i) : null,
                  ),
                if (chosen != null) ExplanationCard(text: q.explanationFor(lang)),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: chosen == null ? null : _next,
                  child: Text(_session.isLast ? s.finish : s.next),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeSummary extends StatelessWidget {
  const _PracticeSummary({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(s.practiceResultTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_outlined, size: 56),
              const SizedBox(height: 12),
              Text(
                s.correctOf(correct, total),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Text(s.backToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
