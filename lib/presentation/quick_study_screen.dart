import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'bookmark_controller.dart';
import 'settings_controller.dart';
import 'strings_context.dart';

class QuickStudyScreen extends StatefulWidget {
  const QuickStudyScreen({super.key, required this.block, required this.questions});

  final QuestionBlock block;
  final List<Question> questions;

  @override
  State<QuickStudyScreen> createState() => _QuickStudyScreenState();
}

class _QuickStudyScreenState extends State<QuickStudyScreen> {
  bool _bookmarkedOnly = false;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsController>().language;
    final bookmarks = context.watch<BookmarkController>();
    final s = context.strings;
    final questions = widget.questions.where((q) => !_bookmarkedOnly || bookmarks.isBookmarked(q.id)).toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.block.nameFor(lang), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text(s.questionCount(questions.length))),
          ),
          IconButton(
            tooltip: _bookmarkedOnly ? s.quickStudyAll : s.quickStudyBookmarked,
            icon: Icon(_bookmarkedOnly ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
            onPressed: () => setState(() => _bookmarkedOnly = !_bookmarkedOnly),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: questions.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(s.quickStudyEmpty, textAlign: TextAlign.center)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) => _StudyCard(question: questions[index], index: index + 1, language: lang),
                ),
        ),
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({required this.question, required this.index, required this.language});

  final Question question;
  final int index;
  final ContentLanguage language;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final scheme = Theme.of(context).colorScheme;
    final bookmarked = context.watch<BookmarkController>().isBookmarked(question.id);
    final options = question.optionsFor(language);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Chip(label: Text(language == ContentLanguage.vi ? 'Câu $index' : 'Question $index')),
            const Spacer(),
            IconButton(
              tooltip: bookmarked ? s.removeBookmark : s.bookmarkTooltip,
              icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: bookmarked ? scheme.primary : null),
              onPressed: () => context.read<BookmarkController>().toggle(question.id),
            ),
          ]),
          Text(question.questionFor(language), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.quickStudyAnswer, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(options[question.correctIndex], style: Theme.of(context).textTheme.bodyLarge),
              ])),
            ]),
          ),
          if (question.explanationFor(language).trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.explanation, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(question.explanationFor(language)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
