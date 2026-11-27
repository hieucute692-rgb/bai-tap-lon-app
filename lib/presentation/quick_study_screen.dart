import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'bookmark_controller.dart';
import 'settings_controller.dart';
import 'strings_context.dart';

class QuickStudyScreen extends StatefulWidget {
  const QuickStudyScreen({
    super.key,
    required this.block,
    required this.questions,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final questions = widget.questions
        .where((q) => !_bookmarkedOnly || bookmarks.isBookmarked(q.id))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.block.nameFor(lang),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHigh : const Color(0xFFE9ECF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              s.questionCount(questions.length),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: _bookmarkedOnly ? s.quickStudyAll : s.quickStudyBookmarked,
            icon: Icon(
              _bookmarkedOnly
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _bookmarkedOnly
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF475569),
            ),
            onPressed: () => setState(() => _bookmarkedOnly = !_bookmarkedOnly),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: questions.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? scheme.surfaceContainerHigh : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : const Color(0xFFE8ECF7),
                  ),
                ),
                child: Text(
                  s.quickStudyEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            itemCount: questions.length,
            itemBuilder: (context, index) => _StudyCard(
              question: questions[index],
              index: index + 1,
              language: lang,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.question,
    required this.index,
    required this.language,
  });

  final Question question;
  final int index;
  final ContentLanguage language;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final bookmarked =
    context.watch<BookmarkController>().isBookmarked(question.id);
    final options = question.optionsFor(language);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE3EEFF), Color(0xFFEDE9FE)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    language == ContentLanguage.vi
                        ? 'Câu $index'
                        : 'Question $index',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: bookmarked ? s.removeBookmark : s.bookmarkTooltip,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: bookmarked
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                  ),
                  onPressed: () =>
                      context.read<BookmarkController>().toggle(question.id),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              question.questionFor(language),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.quickStudyAnswer,
                          style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF15803D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          options[question.correctIndex],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF14532D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (question.explanationFor(language).trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.surfaceContainerHigh
                      : const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.explanation,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      question.explanationFor(language),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}