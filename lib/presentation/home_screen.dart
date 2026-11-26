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
              LoadStatus.ready => c.bank!.isEmpty
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
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.questionsAndBlocks(
                            bank.questions.length, bank.blocks.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _LanguageBlock(
                  language: settings.language, onChanged: settings.setLanguage),
              _ThemeModeBlock(
                mode: settings.themeMode,
                onChanged: settings.setThemeMode,
                appearanceLabel: s.appearance,
                lightLabel: s.themeLight,
                systemLabel: s.themeSystem,
                darkLabel: s.themeDark,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressCard(
            completed: completed,
            total: bank.questions.length,
            correct: correct,
            wrong: wrong.length,
            remaining: remaining,
            label: s.language == ContentLanguage.vi
                ? 'Tiến độ học'
                : 'Learning progress',
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
                    onTap: () =>
                        _push(context, PracticeSetupScreen(bank: bank)),
                  ),
                  _ActionTile(
                    icon: Icons.timer_outlined,
                    title: s.exam,
                    background: scheme.tertiaryContainer,
                    foreground: scheme.onTertiaryContainer,
                    onTap: () => _push(context, ExamSetupScreen(bank: bank)),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageBlock extends StatelessWidget {
  const _LanguageBlock({required this.language, required this.onChanged});

  final ContentLanguage language;
  final ValueChanged<ContentLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SegmentedButton<ContentLanguage>(
      segments: const [
        ButtonSegment(value: ContentLanguage.vi, label: Text('VI')),
        ButtonSegment(value: ContentLanguage.en, label: Text('EN')),
      ],
      selected: {language},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurfaceVariant,
        selectedBackgroundColor: scheme.primary,
        selectedForegroundColor: scheme.onPrimary,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
    );
  }
}

class _ThemeModeBlock extends StatelessWidget {
  const _ThemeModeBlock({
    required this.mode,
    required this.onChanged,
    required this.appearanceLabel,
    required this.lightLabel,
    required this.systemLabel,
    required this.darkLabel,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  final String appearanceLabel;
  final String lightLabel;
  final String systemLabel;
  final String darkLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
    return PopupMenuButton<ThemeMode>(
      tooltip: appearanceLabel,
      initialValue: mode,
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(value: ThemeMode.light, child: Text(lightLabel)),
        PopupMenuItem(value: ThemeMode.dark, child: Text(darkLabel)),
        PopupMenuItem(value: ThemeMode.system, child: Text(systemLabel)),
      ],
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: scheme.onSurfaceVariant),
      ),
    );
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
  });

  final int completed;
  final int total;
  final int correct;
  final int wrong;
  final int remaining;
  final String label;

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
