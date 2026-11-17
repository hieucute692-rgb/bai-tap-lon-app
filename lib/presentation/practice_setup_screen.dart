import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress_stats.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'practice_screen.dart';
import 'progress_controller.dart';
import 'settings_controller.dart';

/// Chọn phạm vi luyện tập: tất cả hoặc một khối kiến thức.
class PracticeSetupScreen extends StatelessWidget {
  const PracticeSetupScreen({super.key, required this.bank});

  final QuestionBank bank;

  void _start(BuildContext context, PracticeTitle titleOf, List<Question> questions) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(titleOf: titleOf, questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final settings = context.watch<SettingsController>();
    final lang = settings.language;
    final s = settings.strings;
    final blocks = computeBlockProgress(bank, progress.stats);
    return Scaffold(
      appBar: AppBar(title: Text(s.practice)),
      body: ListView(
        children: [
          ListTile(
            minVerticalPadding: 12,
            leading: const CircleAvatar(child: Icon(Icons.all_inclusive)),
            title: Text(s.allBlocks),
            subtitle: Text(s.questionCount(bank.questions.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _start(context, (s) => s.practiceAll, bank.questions),
          ),
          for (final p in blocks)
            ListTile(
              minVerticalPadding: 12,
              leading: CircleAvatar(child: Text('${p.block.id}')),
              title: Text(p.block.nameFor(lang)),
              subtitle: Text(
                '${lang == ContentLanguage.vi ? p.block.nameEn : p.block.nameVi}'
                ' · ${s.practiceDone(p.answered, p.total)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _start(
                context,
                (s) => s.blockTitle(p.block.id, p.block.nameFor(s.language)),
                bank.inBlock(p.block.id),
              ),
            ),
        ],
      ),
    );
  }
}
