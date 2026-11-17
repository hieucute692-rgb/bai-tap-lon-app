import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress_stats.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'exam_setup_screen.dart';
import 'practice_screen.dart';
import 'practice_setup_screen.dart';
import 'progress_controller.dart';
import 'question_bank_controller.dart';
import 'settings_controller.dart';
import 'stats_screen.dart';
import 'strings_context.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<QuestionBankController>();
    final s = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      body: switch (c.status) {
        LoadStatus.loading => const Center(child: CircularProgressIndicator()),
        LoadStatus.error => _Message(
            icon: Icons.error_outline,
            text: s.bankLoadError,
            actionLabel: s.retry,
            onAction: c.load,
          ),
        LoadStatus.ready => c.bank!.isEmpty
            ? _Message(
                icon: Icons.inbox_outlined,
                text: s.noQuestions,
                actionLabel: s.reload,
                onAction: c.load,
              )
            : _Menu(bank: c.bank!),
      },
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.bank});

  final QuestionBank bank;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final settings = context.watch<SettingsController>();
    final s = settings.strings;
    final wrong = wrongQuestions(bank, progress.stats);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.questionsAndBlocks(bank.questions.length, bank.blocks.length),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _LanguageCard(
          title: s.displayLanguage,
          language: settings.language,
          onChanged: settings.setLanguage,
        ),
        _MenuCard(
          icon: Icons.menu_book_outlined,
          title: s.practice,
          subtitle: s.practiceSubtitle,
          onTap: () => _push(context, PracticeSetupScreen(bank: bank)),
        ),
        _MenuCard(
          icon: Icons.timer_outlined,
          title: s.exam,
          subtitle: s.examSubtitle,
          onTap: () => _push(context, ExamSetupScreen(bank: bank)),
        ),
        _MenuCard(
          icon: Icons.bar_chart,
          title: s.stats,
          subtitle: s.statsSubtitle,
          onTap: () => _push(context, StatsScreen(bank: bank)),
        ),
        _MenuCard(
          icon: Icons.replay,
          title: s.retryWrong,
          subtitle: wrong.isEmpty ? s.noWrongSubtitle : s.wrongCount(wrong.length),
          onTap: () {
            if (wrong.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.noWrongYet)),
              );
              return;
            }
            _push(
              context,
              PracticeScreen(titleOf: (s) => s.retryWrong, questions: wrong),
            );
          },
        ),
      ],
    );
  }
}

/// Chọn ngôn ngữ hiển thị cho cả app (chữ giao diện và nội dung câu hỏi).
class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.language,
    required this.onChanged,
  });

  final String title;
  final ContentLanguage language;
  final ValueChanged<ContentLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ContentLanguage>(
                segments: const <ButtonSegment<ContentLanguage>>[
                  ButtonSegment(value: ContentLanguage.vi, label: Text('Tiếng Việt')),
                  ButtonSegment(value: ContentLanguage.en, label: Text('English')),
                ],
                selected: {language},
                showSelectedIcon: false,
                onSelectionChanged: (s) => onChanged(s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minVerticalPadding: 16,
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
