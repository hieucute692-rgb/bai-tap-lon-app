import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'bookmark_controller.dart';
import 'settings_controller.dart';
import 'strings_context.dart';

class SearchQuestionsScreen extends StatefulWidget {
  const SearchQuestionsScreen({super.key, required this.bank});

  final QuestionBank bank;

  @override
  State<SearchQuestionsScreen> createState() => _SearchQuestionsScreenState();
}

class _SearchQuestionsScreenState extends State<SearchQuestionsScreen> {
  final _queryController = TextEditingController();
  int? _blockId;
  bool _showAnswers = false;
  late final List<_SearchEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = [
      for (final question in widget.bank.questions)
        _SearchEntry(question, _searchableText(question)),
    ];
  }

  String _searchableText(Question q) => [
    q.questionVi,
    q.questionEn,
    ...q.optionsVi,
    ...q.optionsEn,
    q.explanationVi,
    q.explanationEn,
    q.blockNameVi,
    q.blockNameEn,
  ].join(' ').toLowerCase();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsController>().language;
    final s = context.strings;
    final query = _queryController.text.trim().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final results = _entries
        .where((entry) =>
    (_blockId == null || entry.question.blockId == _blockId) &&
        (query.isEmpty || entry.searchableText.contains(query)))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark ? scheme.surfaceContainerHigh : const Color(0xFFE9ECF5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: _queryController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: s.searchPrompt,
              hintStyle: TextStyle(
                color: isDark
                    ? scheme.onSurfaceVariant
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF2563EB),
                size: 21,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                tooltip: lang == ContentLanguage.vi ? 'Xóa' : 'Clear',
                icon: const Icon(Icons.close_rounded, size: 19),
                onPressed: () {
                  _queryController.clear();
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  children: [
                    _PillChip(
                      label: s.searchAllBlocks,
                      selected: _blockId == null,
                      onTap: () => setState(() => _blockId = null),
                    ),
                    for (final block in widget.bank.blocks)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _PillChip(
                          label:
                          '${lang == ContentLanguage.vi ? 'Khối' : 'Block'} ${block.id}',
                          selected: _blockId == block.id,
                          onTap: () => setState(() => _blockId = block.id),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${s.searchFound} ${results.length} ${s.searchResults}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? scheme.onSurfaceVariant
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _ToggleAnswerChip(
                      label: s.searchShowAnswers,
                      selected: _showAnswers,
                      onTap: () => setState(() => _showAnswers = !_showAnswers),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: query.isEmpty
                    ? _Suggestions(
                  onSelect: (value) {
                    _queryController.text = value;
                    setState(() {});
                  },
                )
                    : results.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      s.searchEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                  itemCount: results.length,
                  itemBuilder: (context, index) => _ResultCard(
                    question: results[index].question,
                    language: lang,
                    showAnswers: _showAnswers,
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

class _SearchEntry {
  const _SearchEntry(this.question, this.searchableText);
  final Question question;
  final String searchableText;
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: selected
                ? null
                : (isDark ? scheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? Colors.white
                  : (isDark
                  ? scheme.onSurface
                  : const Color(0xFF334155)),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleAnswerChip extends StatelessWidget {
  const _ToggleAnswerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFDCFCE7)
                : (isDark ? scheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF86EFAC)
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_outlined,
                size: 15,
                color: selected
                    ? const Color(0xFF15803D)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected
                      ? const Color(0xFF15803D)
                      : (isDark
                      ? scheme.onSurface
                      : const Color(0xFF334155)),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onSelect});
  final ValueChanged<String> onSelect;

  static const _keywords = [
    'Widget',
    'State',
    'Navigator',
    'Future',
    'Layout',
    'BuildContext',
    'StreamBuilder',
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isDark
              ? null
              : const LinearGradient(
            colors: [
              Color(0xFFEEF4FF),
              Color(0xFFFDFDFF),
              Color(0xFFF3EEFF),
            ],
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
              color: const Color(0xFF3B82F6).withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3EEFF), Color(0xFFD2E4FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ).createShader(bounds),
                child: const Icon(
                  Icons.manage_search_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.searchHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? scheme.onSurfaceVariant
                    : const Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final keyword in _keywords)
                  Material(
                    color: isDark ? scheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelect(keyword),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          keyword,
                          style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.question,
    required this.language,
    required this.showAnswers,
  });

  final Question question;
  final ContentLanguage language;
  final bool showAnswers;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final bookmark = context.watch<BookmarkController>();
    final saved = bookmark.isBookmarked(question.id);
    final options = question.optionsFor(language);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : const Color(0xFFE8ECF7),
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
                    '${language == ContentLanguage.vi ? 'Khối' : 'Block'} ${question.blockId} · ${s.questionLabel(question.id)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: saved ? s.removeBookmark : s.bookmarkTooltip,
                  icon: Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: saved
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
            const SizedBox(height: 10),
            for (var i = 0; i < options.length; i++)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: showAnswers && i == question.correctIndex
                      ? const Color(0xFFDCFCE7)
                      : (isDark
                      ? scheme.surfaceContainerHigh
                      : const Color(0xFFF6F7FB)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: showAnswers && i == question.correctIndex
                        ? const Color(0xFF4ADE80)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAnswers && i == question.correctIndex) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        options[i],
                        style: TextStyle(
                          color: showAnswers && i == question.correctIndex
                              ? const Color(0xFF15803D)
                              : null,
                          fontWeight: showAnswers && i == question.correctIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (showAnswers &&
                question.explanationFor(language).trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 4),
                    Text(
                      question.explanationFor(language),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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