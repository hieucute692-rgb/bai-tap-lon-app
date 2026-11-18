import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/format.dart';
import '../domain/progress.dart';
import '../domain/progress_stats.dart';
import '../domain/question_bank.dart';
import 'exam_history_detail_screen.dart';
import 'progress_controller.dart';
import 'question_bank_controller.dart';
import 'settings_controller.dart';

/// Thống kê theo khối kiến thức và lịch sử thi thử.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.bank});

  final QuestionBank bank;

  static String _problemText(ProgressProblem p, AppStrings s) => switch (p) {
        ProgressProblem.loadFailed => s.progressLoadProblem,
        ProgressProblem.saveFailed => s.progressSaveProblem,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ProgressController>();
    final settings = context.watch<SettingsController>();
    final s = settings.strings;
    return Scaffold(
      appBar: AppBar(title: Text(s.stats)),
      body: switch (c.status) {
        LoadStatus.ready => _content(context, c, settings),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BuildContext context, ProgressController c, SettingsController settings) {
    final lang = settings.language;
    final s = settings.strings;
    final blocks = computeBlockProgress(bank, c.stats);
    final answered = blocks.fold<int>(0, (sum, b) => sum + b.answered);
    final attempts = blocks.fold<int>(0, (sum, b) => sum + b.attempts);
    final correct = blocks.fold<int>(0, (sum, b) => sum + b.correct);

    if (attempts == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart, size: 48),
              const SizedBox(height: 12),
              Text(s.statsEmpty, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.statsBack),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final problem = c.problem;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (problem != null)
          Container(
            color: theme.colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber),
                const SizedBox(width: 8),
                Expanded(child: Text(_problemText(problem, s))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.statsAnswered(answered, bank.questions.length),
                style: theme.textTheme.titleMedium,
              ),
              Text(s.statsAccuracy((100 * correct / attempts).round(), correct, attempts)),
            ],
          ),
        ),
        for (final b in blocks)
          ListTile(
            title: Text(s.blockTitle(b.block.id, b.block.nameFor(lang))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: b.accuracy ?? 0,
                  semanticsLabel: s.accuracyForBlock(b.block.id),
                ),
                const SizedBox(height: 4),
                Text(
                  b.attempts == 0
                      ? s.blockNotStarted(b.total)
                      : s.blockStatsLine(
                          percent: (b.accuracy! * 100).round(),
                          correct: b.correct,
                          attempts: b.attempts,
                          answered: b.answered,
                          total: b.total,
                          wrong: b.wrong,
                        ),
                ),
              ],
            ),
          ),
        if (c.examResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(s.examHistory, style: theme.textTheme.titleMedium),
          ),
          for (final ExamResult r in c.examResults)
            ListTile(
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: Text(s.examHistoryEntry(r.correct, r.total, r.score10.toStringAsFixed(1))),
              subtitle: Text('${formatDayTime(r.takenAt)} · ${s.tapToReview}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ExamHistoryDetailScreen(bank: bank, result: r),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
