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

  void _start(
      BuildContext context,
      PracticeTitle titleOf,
      List<Question> questions,
      ) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final blocks = computeBlockProgress(bank, progress.stats);

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.practice,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _ScopeCard(
                icon: Icons.all_inclusive_rounded,
                title: s.allBlocks,
                subtitle: s.questionCount(bank.questions.length),
                progressRatio: bank.questions.isEmpty
                    ? 0
                    : bank.questions
                    .where((q) => (progress.stats[q.id]?.attempts ?? 0) > 0)
                    .length /
                    bank.questions.length,
                gradientColors: const [Color(0xFFEEF4FF), Color(0xFFF3EEFF)],
                iconBg: const [Color(0xFFE3EEFF), Color(0xFFD2E4FF)],
                iconFg: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                onTap: () =>
                    _start(context, (s) => s.practiceAll, bank.questions),
              ),
              const SizedBox(height: 18),
              Text(
                lang == ContentLanguage.vi ? 'THEO KHỐI KIẾN THỨC' : 'BY KNOWLEDGE BLOCK',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              for (final p in blocks) ...[
                _BlockProgressTile(
                  blockId: p.block.id,
                  title: p.block.nameFor(lang),
                  subtitle:
                  '${lang == ContentLanguage.vi ? p.block.nameEn : p.block.nameVi} · ${s.practiceDone(p.answered, p.total)}',
                  answered: p.answered,
                  total: p.total,
                  onTap: () => _start(
                    context,
                        (s) => s.blockTitle(p.block.id, p.block.nameFor(s.language)),
                    bank.inBlock(p.block.id),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeCard extends StatelessWidget {
  const _ScopeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progressRatio,
    required this.gradientColors,
    required this.iconBg,
    required this.iconFg,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double progressRatio;
  final List<Color> gradientColors;
  final List<Color> iconBg;
  final List<Color> iconFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final clamped = progressRatio.clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isDark
                ? null
                : LinearGradient(
              colors: gradientColors,
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: iconBg,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: iconFg,
                      ).createShader(bounds),
                      child: Icon(icon, size: 26, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark ? scheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 6,
                  color: const Color(0xFFDCE4F7),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: clamped,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockProgressTile extends StatelessWidget {
  const _BlockProgressTile({
    required this.blockId,
    required this.title,
    required this.subtitle,
    required this.answered,
    required this.total,
    required this.onTap,
  });

  final int blockId;
  final String title;
  final String subtitle;
  final int answered;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final ratio = total == 0 ? 0.0 : (answered / total).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3EEFF), Color(0xFFEDE9FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  '$blockId',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF1E40AF),
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
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
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
    );
  }
}