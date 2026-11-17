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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<QuestionBankController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập Flutter')),
      body: switch (c.status) {
        LoadStatus.loading => const Center(child: CircularProgressIndicator()),
        LoadStatus.error => _Message(
            icon: Icons.error_outline,
            text: c.errorMessage ?? 'Đã xảy ra lỗi.',
            actionLabel: 'Thử lại',
            onAction: c.load,
          ),
        LoadStatus.ready => c.bank!.isEmpty
            ? _Message(
                icon: Icons.inbox_outlined,
                text: 'Chưa có câu hỏi nào.',
                actionLabel: 'Tải lại',
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
    final wrong = wrongQuestions(bank, progress.stats);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${bank.questions.length} câu · ${bank.blocks.length} khối kiến thức',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _LanguageCard(language: settings.language, onChanged: settings.setLanguage),
        _MenuCard(
          icon: Icons.menu_book_outlined,
          title: 'Luyện tập',
          subtitle: 'Làm theo khối, biết đúng sai và xem giải thích ngay',
          onTap: () => _push(context, PracticeSetupScreen(bank: bank)),
        ),
        _MenuCard(
          icon: Icons.timer_outlined,
          title: 'Thi thử',
          subtitle: 'Bốc ngẫu nhiên theo tỉ lệ các khối, chấm khi nộp bài',
          onTap: () => _push(context, ExamSetupScreen(bank: bank)),
        ),
        _MenuCard(
          icon: Icons.bar_chart,
          title: 'Thống kê',
          subtitle: 'Tỉ lệ đúng theo từng khối và lịch sử thi thử',
          onTap: () => _push(context, StatsScreen(bank: bank)),
        ),
        _MenuCard(
          icon: Icons.replay,
          title: 'Làm lại câu sai',
          subtitle: wrong.isEmpty ? 'Chưa có câu sai' : '${wrong.length} câu đang sai',
          onTap: () {
            if (wrong.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chưa có câu sai nào. Hãy luyện tập hoặc thi thử trước.'),
                ),
              );
              return;
            }
            _push(context, PracticeScreen(title: 'Làm lại câu sai', questions: wrong));
          },
        ),
      ],
    );
  }
}

/// Chọn ngôn ngữ hiển thị nội dung câu hỏi cho toàn bộ app.
class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.language, required this.onChanged});

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
                Text(
                  'Ngôn ngữ câu hỏi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
