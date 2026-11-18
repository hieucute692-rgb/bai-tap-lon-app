import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/progress_stats.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'app_theme.dart';
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
    return Scaffold(
      body: SafeArea(
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.questionsAndBlocks(bank.questions.length, bank.blocks.length),
            style: const TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _LanguageBlock(
            label: s.displayLanguage,
            language: settings.language,
            onChanged: settings.setLanguage,
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
              colors: AppColors.exam,
              title: s.exam,
              subtitle: s.examShort,
              onTap: () => _push(context, ExamSetupScreen(bank: bank)),
            ),
            right: _Tile(
              icon: Icons.bar_chart,
              colors: AppColors.stats,
              title: s.stats,
              subtitle: s.statsShort,
              onTap: () => _push(context, StatsScreen(bank: bank)),
            ),
          ),
          const SizedBox(height: 12),
          _TileRow(
            left: _Tile(
              icon: Icons.replay,
              colors: AppColors.retry,
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
              colors: AppColors.bookmark,
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
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
              backgroundColor: Colors.white,
              foregroundColor: AppColors.muted,
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              side: const BorderSide(color: AppColors.outline),
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
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        button: true,
        label: '$title. $subtitle',
        excludeSemantics: true,
        child: Material(
          color: AppColors.primary,
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
                      color: AppColors.translucentWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.onPrimarySoft),
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
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final TileColors colors;
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
        color: colors.background,
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
                      Icon(icon, size: 28, color: colors.icon),
                      if (badge != null) _Badge(count: badge!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12.5, color: colors.subtitle),
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
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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
