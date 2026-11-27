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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.stats,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: switch (c.status) {
        LoadStatus.ready => _content(context, c, settings),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(
      BuildContext context,
      ProgressController c,
      SettingsController settings,
      ) {
    final lang = settings.language;
    final s = settings.strings;
    final blocks = computeBlockProgress(bank, c.stats);
    final answered = blocks.fold<int>(0, (sum, b) => sum + b.answered);
    final attempts = blocks.fold<int>(0, (sum, b) => sum + b.attempts);
    final correct = blocks.fold<int>(0, (sum, b) => sum + b.correct);
    final examResults = c.examResults;
    final hasPracticeStats = attempts > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    if (!hasPracticeStats && examResults.isEmpty) {
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 30,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  s.statsEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        s.statsBack,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final problem = c.problem;
    final accuracyPercent =
    attempts == 0 ? 0 : (100 * correct / attempts).round();
    final accuracyRatio =
    attempts == 0 ? 0.0 : (correct / attempts).clamp(0.0, 1.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            if (problem != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFBE123C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _problemText(problem, s),
                        style: const TextStyle(
                          color: Color(0xFF9F1239),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (hasPracticeStats) ...[
              Container(
                padding: const EdgeInsets.all(18),
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
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.statsAnswered(answered, bank.questions.length),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.statsAccuracy(accuracyPercent, correct, attempts),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      label: s.stats,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          height: 7,
                          color: const Color(0xFFDCE4F7),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: accuracyRatio,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final b in blocks) ...[
                _BlockStatCard(
                  title: s.blockTitle(b.block.id, b.block.nameFor(lang)),
                  accuracy: b.accuracy,
                  semanticsLabel: s.accuracyForBlock(b.block.id),
                  detail: b.attempts == 0
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
                const SizedBox(height: 10),
              ],
            ],
            if (examResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                s.examStats.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ExamSummary(results: examResults, strings: s),
              const SizedBox(height: 20),
              Text(
                s.examHistory.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              for (final ExamResult r in examResults) ...[
                _ExamHistoryCard(
                  result: r,
                  strings: s,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ExamHistoryDetailScreen(bank: bank, result: r),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BlockStatCard extends StatelessWidget {
  const _BlockStatCard({
    required this.title,
    required this.accuracy,
    required this.semanticsLabel,
    required this.detail,
  });

  final String title;
  final double? accuracy;
  final String semanticsLabel;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final ratio = (accuracy ?? 0.0).clamp(0.0, 1.0);
    final percentText = accuracy == null ? '—' : '${(ratio * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                percentText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            label: semanticsLabel,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                height: 6,
                color: const Color(0xFFE4E7F1),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final scores = results.map((result) => result.score10).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final best = scores.reduce((a, b) => a > b ? a : b);
    final latest = scores.first;

    final metrics = [
      (
      s.examCount,
      results.length.toString(),
      const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      ),
      (
      s.examAverageScore,
      average.toStringAsFixed(1),
      const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      ),
      (
      s.examBestScore,
      best.toStringAsFixed(1),
      const [Color(0xFFFF9A44), Color(0xFFFF3D77)],
      ),
      (
      s.examLatestScore,
      latest.toStringAsFixed(1),
      const [Color(0xFF2563EB), Color(0xFF7C3AED)],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? scheme.surfaceContainer : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: metric.$3,
                        ).createShader(bounds),
                        child: Text(
                          metric.$2,
                          style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ExamHistoryCard extends StatelessWidget {
  const _ExamHistoryCard({
    required this.result,
    required this.strings,
    required this.onTap,
  });

  final ExamResult result;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? scheme.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3EEFF), Color(0xFFEDE9FE)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.examHistoryEntry(
                        result.correct,
                        result.total,
                        result.score10.toStringAsFixed(1),
                      ),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatDayTime(result.takenAt)} · ${strings.tapToReview}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}