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
    final examResults = c.examResults;
    final hasPracticeStats = attempts > 0;

    if (!hasPracticeStats && examResults.isEmpty) {
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
        if (hasPracticeStats) ...[
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
        ],
        if (examResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(s.examStats, style: theme.textTheme.titleMedium),
          ),
          _ExamSummary(results: examResults, strings: s),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(s.examHistory, style: theme.textTheme.titleMedium),
          ),
          for (final ExamResult r in examResults)
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

class _ExamSummary extends StatelessWidget {
  const _ExamSummary({required this.results, required this.strings});

  final List<ExamResult> results;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final scheme = Theme.of(context).colorScheme;
    final scores = results.map((result) => result.score10).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final best = scores.reduce((a, b) => a > b ? a : b);
    final latest = scores.first;
    final metrics = [
      (s.examCount, results.length.toString()),
      (s.examAverageScore, average.toStringAsFixed(1)),
      (s.examBestScore, best.toStringAsFixed(1)),
      (s.examLatestScore, latest.toStringAsFixed(1)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: width,
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: scheme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.$1,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metric.$2,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

}
