import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/format.dart';
import '../domain/progress.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import '../domain/question_text.dart';
import 'app_theme.dart';
import 'settings_controller.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/explanation_card.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Xem lại chi tiết một lần thi thử trong lịch sử: từng câu, đáp án đã chọn, đáp án đúng
/// và giải thích. Có thể lọc chỉ các câu sai hoặc bỏ trống.
class ExamHistoryDetailScreen extends StatefulWidget {
  const ExamHistoryDetailScreen({super.key, required this.bank, required this.result});

  final QuestionBank bank;
  final ExamResult result;

  @override
  State<ExamHistoryDetailScreen> createState() => _ExamHistoryDetailScreenState();
}

class _Entry {
  const _Entry(this.question, this.chosen);

  final Question question;
  final int? chosen;

  bool get answered => chosen != null;
  bool get correct => chosen == question.correctIndex;
}

class _ExamHistoryDetailScreenState extends State<ExamHistoryDetailScreen> {
  bool _onlyWrong = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final s = settings.strings;
    final lang = settings.language;
    final result = widget.result;

    final byId = {for (final q in widget.bank.questions) q.id: q};
    final entries = [
      for (final a in result.answers)
        if (byId[a.questionId] != null) _Entry(byId[a.questionId]!, a.chosen),
    ];
    final shown = _onlyWrong ? entries.where((e) => !e.correct).toList() : entries;

    return Scaffold(
      appBar: AppBar(title: Text(s.examDetailTitle)),
      body: entries.isEmpty
          ? _Unavailable(message: s.examDetailUnavailable, back: s.goBack)
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.correctOf(result.correct, result.total),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(s.scoreOf(result.score10.toStringAsFixed(1))),
                      Text(
                        formatDayTime(result.takenAt),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(value: false, label: Text(s.filterAll)),
                            ButtonSegment<bool>(value: true, label: Text(s.filterWrong)),
                          ],
                          selected: {_onlyWrong},
                          showSelectedIcon: false,
                          onSelectionChanged: (sel) => setState(() => _onlyWrong = sel.first),
                        ),
                      ),
                    ],
                  ),
                ),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(s.allCorrect, textAlign: TextAlign.center),
                  ),
                for (final e in shown)
                  _DetailTile(key: ValueKey(e.question.id), entry: e, lang: lang, strings: s),
              ],
            ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    super.key,
    required this.entry,
    required this.lang,
    required this.strings,
  });

  final _Entry entry;
  final ContentLanguage lang;
  final AppStrings strings;

  String _preview(String text) {
    final segments = parseQuestionText(text);
    return segments.isEmpty ? '' : segments.first.content;
  }

  @override
  Widget build(BuildContext context) {
    final q = entry.question;
    final options = q.optionsFor(lang);
    final status = !entry.answered
        ? strings.statusUnanswered
        : entry.correct
            ? strings.statusCorrect
            : strings.statusWrong;
    final icon = !entry.answered
        ? Icons.remove_circle_outline
        : entry.correct
            ? Icons.check_circle
            : Icons.cancel;
    final color = !entry.answered
        ? AppColors.muted
        : entry.correct
            ? AppColors.stats.icon
            : AppColors.retry.icon;
    final pick = entry.chosen;

    return ExpansionTile(
      leading: Icon(icon, color: color),
      title: Text('${strings.questionLabel(q.id)} · $status'),
      subtitle: Text(
        _preview(q.questionFor(lang)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: BookmarkButton(questionId: q.id),
        ),
        QuestionText(q.questionFor(lang)),
        const SizedBox(height: 8),
        for (var i = 0; i < options.length; i++)
          OptionTile(
            letter: 'ABCD'[i],
            text: options[i],
            state: i == q.correctIndex
                ? OptionState.correct
                : i == pick
                    ? OptionState.wrong
                    : OptionState.idle,
          ),
        const SizedBox(height: 8),
        Text(
          pick == null ? strings.notAnswered : strings.youChose('ABCD'[pick], options[pick]),
        ),
        Text(strings.correctAnswer('ABCD'[q.correctIndex], options[q.correctIndex])),
        ExplanationCard(text: q.explanationFor(lang)),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message, required this.back});

  final String message;
  final String back;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_toggle_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(back)),
          ],
        ),
      ),
    );
  }
}
