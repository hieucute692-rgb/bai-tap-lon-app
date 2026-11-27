import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/format.dart';
import '../domain/progress.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import '../domain/question_text.dart';
import 'settings_controller.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/explanation_card.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Xem lại chi tiết một lần thi thử trong lịch sử: từng câu, đáp án đã chọn, đáp án đúng
/// và giải thích. Có thể lọc chỉ các câu sai hoặc bỏ trống.
class ExamHistoryDetailScreen extends StatefulWidget {
  const ExamHistoryDetailScreen({
    super.key,
    required this.bank,
    required this.result,
  });

  final QuestionBank bank;
  final ExamResult result;

  @override
  State<ExamHistoryDetailScreen> createState() =>
      _ExamHistoryDetailScreenState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final byId = {for (final q in widget.bank.questions) q.id: q};
    final entries = [
      for (final a in result.answers)
        if (byId[a.questionId] != null) _Entry(byId[a.questionId]!, a.chosen),
    ];
    final shown =
    _onlyWrong ? entries.where((e) => !e.correct).toList() : entries;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.examDetailTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: entries.isEmpty
          ? _Unavailable(message: s.examDetailUnavailable, back: s.goBack)
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: isDark
                      ? null
                      : const LinearGradient(
                    colors: [
                      Color(0xFFEEF4FF),
                      Color(0xFFFDFDFF),
                      Color(0xFFF3EEFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  color: isDark ? scheme.surfaceContainerHigh : null,
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6)
                          .withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.correctOf(result.correct, result.total),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.scoreOf(
                                  result.score10.toStringAsFixed(1),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDayTime(result.takenAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF9A44),
                                Color(0xFFFF3D77),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3D77)
                                    .withValues(alpha: 0.28),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                result.score10.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  height: 1.1,
                                ),
                              ),
                              const Text(
                                '/10',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterTabButton(
                            label: s.filterAll,
                            selected: !_onlyWrong,
                            onTap: () =>
                                setState(() => _onlyWrong = false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FilterTabButton(
                            label: s.filterWrong,
                            selected: _onlyWrong,
                            onTap: () => setState(() => _onlyWrong = true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (shown.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? scheme.surfaceContainer : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : const Color(0xFFE8ECF7),
                    ),
                  ),
                  child: Text(
                    s.allCorrect,
                    textAlign: TextAlign.center,
                    style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (final e in shown)
                _DetailTile(
                  key: ValueKey(e.question.id),
                  entry: e,
                  lang: lang,
                  strings: s,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTabButton extends StatelessWidget {
  const _FilterTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            )
                : null,
            color: selected
                ? null
                : (isDark ? scheme.surface : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? Colors.white
                  : (isDark
                  ? scheme.onSurface
                  : const Color(0xFF334155)),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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
        ? Icons.remove_circle_outline_rounded
        : entry.correct
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final statusColor = !entry.answered
        ? const Color(0xFF64748B)
        : entry.correct
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final badgeBg = !entry.answered
        ? const Color(0xFFE2E8F0)
        : entry.correct
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFFE4E6);

    final pick = entry.chosen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          title: Text(
            '${strings.questionLabel(q.id)} · $status',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
          subtitle: Text(
            _preview(q.questionFor(lang)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: BookmarkButton(questionId: q.id),
            ),
            QuestionText(q.questionFor(lang)),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: pick == null
                    ? const Color(0xFFF1F5F9)
                    : (pick == q.correctIndex
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFFE4E6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pick == null
                    ? strings.notAnswered
                    : strings.youChose('ABCD'[pick], options[pick]),
                style: TextStyle(
                  color: pick == null
                      ? const Color(0xFF475569)
                      : (pick == q.correctIndex
                      ? const Color(0xFF15803D)
                      : const Color(0xFFBE123C)),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                strings.correctAnswer(
                  'ABCD'[q.correctIndex],
                  options[q.correctIndex],
                ),
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ExplanationCard(text: q.explanationFor(lang)),
          ],
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message, required this.back});

  final String message;
  final String back;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? scheme.surfaceContainerHigh : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_toggle_off_rounded, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}