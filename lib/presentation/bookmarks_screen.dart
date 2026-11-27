import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/bookmarks.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import '../domain/question_text.dart';
import 'bookmark_controller.dart';
import 'practice_screen.dart';
import 'question_bank_controller.dart';
import 'settings_controller.dart';
import 'widgets/explanation_card.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Các câu đã đánh dấu: xem lại kèm đáp án và giải thích, bỏ đánh dấu, hoặc luyện tập lại.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key, required this.bank});

  final QuestionBank bank;

  static String _problemText(BookmarkProblem p, AppStrings s) => switch (p) {
    BookmarkProblem.loadFailed => s.bookmarkLoadProblem,
    BookmarkProblem.saveFailed => s.bookmarkSaveProblem,
  };

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkController>();
    final settings = context.watch<SettingsController>();
    final s = settings.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.bookmarks,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: switch (bookmarks.status) {
        LoadStatus.ready => _content(context, bookmarks, settings),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(
      BuildContext context,
      BookmarkController bookmarks,
      SettingsController settings,
      ) {
    final s = settings.strings;
    final lang = settings.language;
    final questions = bookmarkedQuestions(bank, bookmarks.ids);
    final problem = bookmarks.problem;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHigh : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    size: 28,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  s.bookmarksEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.bookmarksEmptyHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        s.goBack,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            if (problem != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFBE123C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _problemText(problem, s),
                        style: const TextStyle(
                          color: Color(0xFF9F1239),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PracticeScreen(
                        titleOf: (s) => s.bookmarkedQuestionsTitle,
                        questions: questions,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    s.practiceBookmarked,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final q in questions)
              _BookmarkedTile(
                key: ValueKey(q.id),
                question: q,
                lang: lang,
                strings: s,
                onRemove: () => bookmarks.toggle(q.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkedTile extends StatelessWidget {
  const _BookmarkedTile({
    super.key,
    required this.question,
    required this.lang,
    required this.strings,
    required this.onRemove,
  });

  final Question question;
  final ContentLanguage lang;
  final AppStrings strings;
  final VoidCallback onRemove;

  String _preview(String text) {
    final segments = parseQuestionText(text);
    return segments.isEmpty ? '' : segments.first.content;
  }

  @override
  Widget build(BuildContext context) {
    final options = question.optionsFor(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            strings.questionLabel(question.id),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E40AF),
            ),
          ),
          subtitle: Text(
            _preview(question.questionFor(lang)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3EEFF), Color(0xFFEDE9FE)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                strings.blockTitle(question.blockId, question.blockNameFor(lang)),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF1E40AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            QuestionText(question.questionFor(lang)),
            const SizedBox(height: 10),
            for (var i = 0; i < options.length; i++)
              OptionTile(
                letter: 'ABCD'[i],
                text: options[i],
                state: i == question.correctIndex
                    ? OptionState.correct
                    : OptionState.idle,
              ),
            const SizedBox(height: 6),
            ExplanationCard(text: question.explanationFor(lang)),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                icon: const Icon(Icons.bookmark_remove_rounded, size: 19),
                label: Text(strings.removeBookmark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}