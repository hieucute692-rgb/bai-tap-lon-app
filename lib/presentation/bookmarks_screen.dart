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
    return Scaffold(
      appBar: AppBar(title: Text(s.bookmarks)),
      body: switch (bookmarks.status) {
        LoadStatus.ready => _content(context, bookmarks, settings),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BuildContext context, BookmarkController bookmarks, SettingsController settings) {
    final s = settings.strings;
    final lang = settings.language;
    final questions = bookmarkedQuestions(bank, bookmarks.ids);
    final problem = bookmarks.problem;

    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_border, size: 48),
              const SizedBox(height: 12),
              Text(s.bookmarksEmpty, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(s.bookmarksEmptyHint, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.goBack),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (problem != null)
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber),
                const SizedBox(width: 8),
                Expanded(child: Text(_problemText(problem, s))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PracticeScreen(
                  titleOf: (s) => s.bookmarkedQuestionsTitle,
                  questions: questions,
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(s.practiceBookmarked),
          ),
        ),
        for (final q in questions)
          _BookmarkedTile(
            key: ValueKey(q.id),
            question: q,
            lang: lang,
            strings: s,
            onRemove: () => bookmarks.toggle(q.id),
          ),
      ],
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
    return ExpansionTile(
      title: Text(strings.questionLabel(question.id)),
      subtitle: Text(
        _preview(question.questionFor(lang)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.blockTitle(question.blockId, question.blockNameFor(lang)),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        QuestionText(question.questionFor(lang)),
        const SizedBox(height: 8),
        for (var i = 0; i < options.length; i++)
          OptionTile(
            letter: 'ABCD'[i],
            text: options[i],
            state: i == question.correctIndex ? OptionState.correct : OptionState.idle,
          ),
        ExplanationCard(text: question.explanationFor(lang)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.bookmark_remove_outlined),
            label: Text(strings.removeBookmark),
          ),
        ),
      ],
    );
  }
}
