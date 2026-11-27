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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.quickStudy,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              final p = blocks[index];
              final ratio =
              p.total == 0 ? 0.0 : (p.answered / p.total).clamp(0.0, 1.0);
              final percent = (ratio * 100).round();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuickStudyScreen(
                          block: p.block,
                          questions: bank.inBlock(p.block.id),
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? scheme.surfaceContainer : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                          isDark ? Colors.white10 : const Color(0xFFE8ECF7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
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
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: Colors.white, width: 1.2),
                            ),
                            child: Text(
                              '${p.block.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.block.nameFor(lang),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$percent%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                        color: const Color(0xFFD97706),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  s.questionCount(p.total),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: Container(
                                    height: 5,
                                    color: const Color(0xFFE4E7F1),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: ratio,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}