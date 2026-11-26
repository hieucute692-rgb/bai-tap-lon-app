import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress_stats.dart';
import '../domain/question_bank.dart';
import 'progress_controller.dart';
import 'quick_study_screen.dart';
import 'settings_controller.dart';
import 'strings_context.dart';

class QuickStudyBlocksScreen extends StatelessWidget {
  const QuickStudyBlocksScreen({super.key, required this.bank});

  final QuestionBank bank;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final lang = context.watch<SettingsController>().language;
    final s = context.strings;
    final blocks = computeBlockProgress(bank, progress.stats);
    return Scaffold(
      appBar: AppBar(title: Text(s.quickStudy)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              final p = blocks[index];
              final ratio = p.total == 0 ? 0.0 : p.answered / p.total;
              return Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(child: Text('${p.block.id}')),
                  title: Text(p.block.nameFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.questionCount(p.total)),
                      const SizedBox(height: 7),
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: ratio, minHeight: 4)),
                    ]),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => QuickStudyScreen(block: p.block, questions: bank.inBlock(p.block.id)),
                  )),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
