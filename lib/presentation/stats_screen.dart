import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress.dart';
import '../domain/progress_stats.dart';
import '../domain/question_bank.dart';
import 'progress_controller.dart';
import 'question_bank_controller.dart';
import 'settings_controller.dart';

/// Thống kê theo khối kiến thức và lịch sử thi thử.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.bank});

  final QuestionBank bank;

  static String _formatTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ProgressController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: switch (c.status) {
        LoadStatus.ready => _content(context, c),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BuildContext context, ProgressController c) {
    final lang = context.watch<SettingsController>().language;
    final blocks = computeBlockProgress(bank, c.stats);
    final answered = blocks.fold<int>(0, (s, b) => s + b.answered);
    final attempts = blocks.fold<int>(0, (s, b) => s + b.attempts);
    final correct = blocks.fold<int>(0, (s, b) => s + b.correct);

    if (attempts == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart, size: 48),
              const SizedBox(height: 12),
              const Text('Bạn chưa làm câu nào.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Quay lại để bắt đầu'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (c.problem != null)
          Container(
            color: theme.colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber),
                const SizedBox(width: 8),
                Expanded(child: Text(c.problem!)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đã làm $answered/${bank.questions.length} câu',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'Tỉ lệ đúng: ${(100 * correct / attempts).round()}% ($correct/$attempts lượt)',
              ),
            ],
          ),
        ),
        for (final b in blocks)
          ListTile(
            title: Text('Khối ${b.block.id}. ${b.block.nameFor(lang)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: b.accuracy ?? 0,
                  semanticsLabel: 'Tỉ lệ đúng khối ${b.block.id}',
                ),
                const SizedBox(height: 4),
                Text(
                  b.attempts == 0
                      ? 'Chưa làm · ${b.total} câu'
                      : 'Đúng ${(b.accuracy! * 100).round()}% (${b.correct}/${b.attempts} lượt)'
                          ' · Đã làm ${b.answered}/${b.total} · Đang sai ${b.wrong}',
                ),
              ],
            ),
          ),
        if (c.examResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Lịch sử thi thử', style: theme.textTheme.titleMedium),
          ),
          for (final ExamResult r in c.examResults)
            ListTile(
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: Text('${r.correct}/${r.total} câu · ${r.score10.toStringAsFixed(1)}/10'),
              subtitle: Text(_formatTime(r.takenAt)),
            ),
        ],
      ],
    );
  }
}
