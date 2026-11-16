import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/question_bank.dart';
import 'block_screen.dart';
import 'question_bank_controller.dart';

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
            : _BlockList(bank: c.bank!),
      },
    );
  }
}

class _BlockList extends StatelessWidget {
  const _BlockList({required this.bank});

  final QuestionBank bank;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${bank.questions.length} câu · ${bank.blocks.length} khối kiến thức',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final b in bank.blocks)
          ListTile(
            minVerticalPadding: 12,
            leading: CircleAvatar(child: Text('${b.id}')),
            title: Text(b.nameVi),
            subtitle: Text('${b.nameEn} · ${b.questionCount} câu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlockScreen(bank: bank, block: b),
              ),
            ),
          ),
      ],
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
