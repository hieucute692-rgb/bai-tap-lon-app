import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress_stats.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'bookmark_controller.dart';
import 'bookmarks_screen.dart';
import 'exam_setup_screen.dart';
import 'practice_screen.dart';
import 'practice_setup_screen.dart';
import 'quick_study_blocks_screen.dart';
import 'search_questions_screen.dart';
import 'progress_controller.dart';
import 'question_bank_controller.dart';
import 'question_manager_screen.dart';
import 'settings_screen.dart';
import 'settings_controller.dart';
import 'stats_screen.dart';
import 'strings_context.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<QuestionBankController>();
    final s = context.strings;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: switch (c.status) {
              LoadStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              LoadStatus.error => _Message(
                  icon: Icons.error_outline,
                  text: s.bankLoadError,
                  actionLabel: s.retry,
                  onAction: c.load,
                ),
              LoadStatus.ready => c.bank == null
                  ? _Message(
                icon: Icons.inbox_outlined,
                text: s.noQuestions,
                actionLabel: s.reload,
                onAction: c.load,
              )
                  : _Menu(bank: c.bank!),
            },
          ),
        ),
      ),
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
    final bookmarks = context.watch<BookmarkController>();
    final bankController = context.watch<QuestionBankController>();
    final s = settings.strings;
    final scheme = Theme.of(context).colorScheme;
    final stats = progress.stats;
    final completed = bank.questions.where((question) {
      final stat = stats[question.id];
      return stat != null && stat.attempts > 0;
    }).length;
    final wrong = wrongQuestions(bank, stats);
    final correct = bank.questions.where((question) {
      final stat = stats[question.id];
      return stat != null && stat.attempts > 0 && stat.lastCorrect;
    }).length;
    final remaining = (bank.questions.length - completed)
        .clamp(0, bank.questions.length)
        .toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _chooseSubject(context, bankController),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                bankController.currentSubject?.name ?? s.appTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 28,
                              color: scheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.questionsAndBlocks(
                          bank.questions.length,
                          bank.blocks.length,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: s.settings,
                onPressed: () => _push(context, const SettingsScreen()),
                icon: Icon(
                  Icons.settings_outlined,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _push(context, SearchQuestionsScreen(bank: bank)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Icon(Icons.search_rounded, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.searchHomePrompt, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant))),
                  Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (bank.isEmpty) ...[
            Card(
              margin: EdgeInsets.zero,
              color: scheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      s.noQuestions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (bankController.currentSubject != null)
                      FilledButton.icon(
                        onPressed: () => _push(
                          context,
                          QuestionFormScreen(
                            subject: bankController.currentSubject!,
                            initialQuestion: null,
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(s.addQuestion),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _ProgressCard(
            completed: completed,
            total: bank.questions.length,
            correct: correct,
            wrong: wrong.length,
            remaining: remaining,
            label: s.language == ContentLanguage.vi
                ? 'Tiến độ học'
                : 'Learning progress',
            dailyGoal: progress.dailyGoal,
            todayAnsweredCount: progress.todayAnsweredCount,
            currentStreak: progress.currentStreak,
            goalComplete: progress.dailyGoalComplete,
            onChooseGoal: () => _chooseDailyGoal(context, progress),
          ),
          const SizedBox(height: 20),
          Text(
            s.language == ContentLanguage.vi
                ? 'CHỨC NĂNG CHÍNH'
                : 'MAIN FEATURES',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surfaceContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActionTile(
                    icon: Icons.menu_book_outlined,
                    title: s.practice,
                    background: scheme.primaryContainer,
                    foreground: scheme.onPrimaryContainer,
                    onTap: () {
                      if (bank.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.noQuestions)),
                        );
                        return;
                      }
                      _push(context, PracticeSetupScreen(bank: bank));
                    },
                  ),
                  _ActionTile(
                    icon: Icons.timer_outlined,
                    title: s.exam,
                    background: scheme.tertiaryContainer,
                    foreground: scheme.onTertiaryContainer,
                    onTap: () {
                      if (bank.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.noQuestions)),
                        );
                        return;
                      }
                      _push(context, ExamSetupScreen(bank: bank));
                    },
                  ),
                  _ActionTile(
                    icon: Icons.bar_chart_rounded,
                    title: s.stats,
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                    onTap: () => _push(context, StatsScreen(bank: bank)),
                  ),
                  _ActionTile(
                    icon: Icons.bolt_rounded,
                    title: s.quickStudy,
                    background: Colors.amber.shade100,
                    foreground: Colors.deepOrange.shade800,
                    onTap: () => _push(context, QuickStudyBlocksScreen(bank: bank)),
                  ),
                  _ActionTile(
                    icon: Icons.replay_rounded,
                    title:
                        s.language == ContentLanguage.vi ? 'Câu sai' : 'Wrong',
                    background: scheme.errorContainer,
                    foreground: scheme.onErrorContainer,
                    badge: wrong.isEmpty ? null : wrong.length,
                    onTap: () {
                      if (wrong.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.noWrongYet)),
                        );
                        return;
                      }
                      _push(
                        context,
                        PracticeScreen(
                            titleOf: (s) => s.retryWrong, questions: wrong),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.bookmark_outline_rounded,
                    title:
                        s.language == ContentLanguage.vi ? 'Đánh dấu' : 'Saved',
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                    badge: bookmarks.count == 0 ? null : bookmarks.count,
                    onTap: () => _push(context, BookmarksScreen(bank: bank)),
                  ),
                  _ActionTile(
                    icon: Icons.folder_open_outlined,
                    title: s.manageQuestions,
                    background: scheme.primaryContainer,
                    foreground: scheme.onPrimaryContainer,
                    onTap: () => _push(context, const QuestionManagerSubjectsScreen()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseDailyGoal(
    BuildContext context,
    ProgressController progress,
  ) async {
    final s = context.stringsNow;
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(s.chooseDailyGoal,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final goal in [10, 15, 30, 45])
                ListTile(
                  title: Text(s.dailyGoalOption(goal)),
                  trailing: progress.dailyGoal == goal
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(goal),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) await progress.setDailyGoal(selected);
  }

  Future<void> _chooseSubject(
      BuildContext context,
      QuestionBankController controller,
      ) async {
    final s = context.stringsNow;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                s.selectSubject,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final sub in controller.subjects)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(sub.name),
                subtitle: Text(sub.fileName),
                trailing: controller.currentSubject?.id == sub.id
                    ? Icon(Icons.check_rounded,
                    color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await controller.selectSubject(sub);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(s.newSubject),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showCreateSubjectDialog(context, controller);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateSubjectDialog(
      BuildContext context,
      QuestionBankController controller,
      ) async {
    final s = context.stringsNow;
    final nameCtrl = TextEditingController();
    final createdName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.newSubject),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(hintText: s.subjectName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.goBack),
          ),
          FilledButton(
            onPressed: () {
              final text = nameCtrl.text.trim();
              if (text.isNotEmpty) Navigator.pop(ctx, text);
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    if (createdName != null && createdName.isNotEmpty) {
      await controller.createSubject(createdName);
    }
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.remaining,
    required this.label,
    required this.dailyGoal,
    required this.todayAnsweredCount,
    required this.currentStreak,
    required this.goalComplete,
    required this.onChooseGoal,
  });

  final int completed;
  final int total;
  final int correct;
  final int wrong;
  final int remaining;
  final String label;
  final int dailyGoal;
  final int todayAnsweredCount;
  final int currentStreak;
  final bool goalComplete;
  final VoidCallback onChooseGoal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = total == 0 ? 0 : (completed * 100 / total).round();
    final progressValue = total == 0 ? 0.0 : completed / total;
    final isVietnamese = context.strings.language == ContentLanguage.vi;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(
                  isVietnamese
                      ? '$completed / $total câu'
                      : '$completed / $total questions',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('$percent%',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ProgressStat(
                  count: correct,
                  label: isVietnamese ? 'đúng' : 'correct',
                  color: Colors.green,
                ),
                _ProgressStat(
                  count: wrong,
                  label: isVietnamese ? 'sai' : 'wrong',
                  color: scheme.error,
                ),
                _ProgressStat(
                  count: remaining,
                  label: isVietnamese ? 'còn lại' : 'remaining',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            context.strings.dailyGoal,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (goalComplete)
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 19),
                        IconButton(
                          tooltip: context.strings.chooseDailyGoal,
                          visualDensity: VisualDensity.compact,
                          constraints:
                              const BoxConstraints.tightFor(width: 34, height: 34),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.tune_rounded, size: 19),
                          onPressed: onChooseGoal,
                        ),
                      ]),
                      Text(
                        context.strings.dailyGoalProgress(
                            todayAnsweredCount, dailyGoal),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          value: (todayAnsweredCount / dailyGoal)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                          color: goalComplete ? Colors.green : scheme.tertiary,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Colors.deepOrange, size: 23),
                      const SizedBox(height: 2),
                      Text(context.strings.studyStreak(currentStreak),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat(
      {required this.count, required this.label, required this.color});

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$count',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: background, borderRadius: radius),
                      child: Icon(icon, size: 28, color: foreground),
                    ),
                    if (badge != null)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: _Badge(count: badge!),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(99)),
      child: Text(
        '$count',
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: scheme.onInverseSurface),
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
