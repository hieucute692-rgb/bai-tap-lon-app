import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress_stats.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'practice_screen.dart';
import 'progress_controller.dart';

/// Chọn phạm vi luyện tập: tất cả hoặc một khối kiến thức.
class PracticeSetupScreen extends StatelessWidget {
  const PracticeSetupScreen({super.key, required this.bank});

  final QuestionBank bank;

  void _start(BuildContext context, String title, List<Question> questions) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(title: title, questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final blocks = computeBlockProgress(bank, progress.stats);
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập')),
      body: ListView(
        children: [
          ListTile(
            minVerticalPadding: 12,
            leading: const CircleAvatar(child: Icon(Icons.all_inclusive)),
            title: const Text('Tất cả các khối'),
            subtitle: Text('${bank.questions.length} câu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _start(context, 'Luyện tập tất cả', bank.questions),
          ),
          for (final p in blocks)
            ListTile(
              minVerticalPadding: 12,
              leading: CircleAvatar(child: Text('${p.block.id}')),
              title: Text(p.block.nameVi),
              subtitle: Text(
                '${p.block.nameEn} · Đã làm ${p.answered}/${p.total}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _start(
                context,
                'Khối ${p.block.id}. ${p.block.nameVi}',
                bank.inBlock(p.block.id),
              ),
            ),
        ],
      ),
    );
  }
}
