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
      backgroundColor: scheme.surfaceContainerHighest,
      body: SafeArea(
<<<<<<< Updated upstream
        child: switch (c.status) {
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
=======
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withOpacity(
                      Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.12,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: switch (c.status) {
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
            ),
          ),
        ),
>>>>>>> Stashed changes
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
    final wrong = wrongQuestions(bank, progress.stats);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              s.appTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.questionsAndBlocks(bank.questions.length, bank.blocks.length),
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _LanguageBlock(
            label: s.displayLanguage,
            language: settings.language,
            onChanged: settings.setLanguage,
          ),
          const SizedBox(height: 12),
          _ThemeModeBlock(
            mode: settings.themeMode,
            onChanged: settings.setThemeMode,
            appearanceLabel: s.appearance,
            lightLabel: s.themeLight,
            systemLabel: s.themeSystem,
            darkLabel: s.themeDark,
          ),
          const SizedBox(height: 16),
          _HeroCard(
            icon: Icons.menu_book_outlined,
            title: s.practice,
            subtitle: s.practiceSubtitle,
            onTap: () => _push(context, PracticeSetupScreen(bank: bank)),
          ),
          const SizedBox(height: 12),
          _TileRow(
            left: _Tile(
              icon: Icons.timer_outlined,
              background: scheme.tertiaryContainer,
              foreground: scheme.onTertiaryContainer,
              title: s.exam,
              subtitle: s.examShort,
              onTap: () => _push(context, ExamSetupScreen(bank: bank)),
            ),
            right: _Tile(
              icon: Icons.bar_chart,
              background: scheme.secondaryContainer,
              foreground: scheme.onSecondaryContainer,
              title: s.stats,
              subtitle: s.statsShort,
              onTap: () => _push(context, StatsScreen(bank: bank)),
            ),
          ),
          const SizedBox(height: 12),
          _TileRow(
            left: _Tile(
              icon: Icons.replay,
              background: scheme.errorContainer,
              foreground: scheme.onErrorContainer,
              title: s.retryWrong,
              subtitle: wrong.isEmpty ? s.noWrongSubtitle : s.wrongCount(wrong.length),
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
                  PracticeScreen(titleOf: (s) => s.retryWrong, questions: wrong),
                );
              },
            ),
            right: _Tile(
              icon: Icons.bookmark_outline,
              background: scheme.primaryContainer,
              foreground: scheme.onPrimaryContainer,
              title: s.bookmarks,
              subtitle: bookmarks.count == 0
                  ? s.noBookmarksSubtitle
                  : s.bookmarkedCount(bookmarks.count),
              badge: bookmarks.count == 0 ? null : bookmarks.count,
              onTap: () => _push(context, BookmarksScreen(bank: bank)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chọn ngôn ngữ hiển thị cho cả app (chữ giao diện và nội dung câu hỏi).
class _LanguageBlock extends StatelessWidget {
  const _LanguageBlock({
    required this.label,
    required this.language,
    required this.onChanged,
  });

  final String label;
  final ContentLanguage language;
  final ValueChanged<ContentLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ContentLanguage>(
            segments: const <ButtonSegment<ContentLanguage>>[
              ButtonSegment(value: ContentLanguage.vi, label: Text('Tiếng Việt')),
              ButtonSegment(value: ContentLanguage.en, label: Text('English')),
            ],
            selected: {language},
            showSelectedIcon: false,
            onSelectionChanged: (sel) => onChanged(sel.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            appearanceLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, label: Text(lightLabel)),
              ButtonSegment(value: ThemeMode.system, label: Text(systemLabel)),
              ButtonSegment(value: ThemeMode.dark, label: Text(darkLabel)),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => onChanged(selection.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurfaceVariant,
              selectedBackgroundColor: scheme.primary,
              selectedForegroundColor: scheme.onPrimary,
              side: BorderSide(color: scheme.outline),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Thẻ lớn nổi bật cho chức năng chính (luyện tập).
class _HeroCard extends StatelessWidget {
  const _HeroCard({
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
    final radius = BorderRadius.circular(24);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        button: true,
        label: '$title. $subtitle',
        excludeSemantics: true,
        child: Material(
          color: scheme.primary,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: scheme.onPrimary),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: scheme.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hai thẻ nhỏ cạnh nhau, luôn cao bằng nhau kể cả khi người dùng tăng cỡ chữ.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 132),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, size: 28, color: foreground),
                      if (badge != null) _Badge(count: badge!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12.5, color: foreground),
                      ),
                    ],
                  ),
                ],
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
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
