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
    final results = _entries
        .where((entry) => (_blockId == null || entry.question.blockId == _blockId) &&
            (query.isEmpty || entry.searchableText.contains(query)))
        .toList(growable: false);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: s.searchPrompt,
            border: InputBorder.none,
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: lang == ContentLanguage.vi ? 'Xóa' : 'Clear',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _queryController.clear();
                      setState(() {});
                    },
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
                height: 54,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  children: [
                    ChoiceChip(
                      label: Text(s.searchAllBlocks),
                      selected: _blockId == null,
                      onSelected: (_) => setState(() => _blockId = null),
                    ),
                    for (final block in widget.bank.blocks)
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: ChoiceChip(
                          label: Text('${lang == ContentLanguage.vi ? 'Khối' : 'Block'} ${block.id}'),
                          selected: _blockId == block.id,
                          onSelected: (_) => setState(() => _blockId = block.id),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${s.searchFound} ${results.length} ${s.searchResults}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                    FilterChip(
                      label: Text(s.searchShowAnswers),
                      selected: _showAnswers,
                      onSelected: (value) => setState(() => _showAnswers = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: query.isEmpty
                    ? _Suggestions(onSelect: (value) {
                        _queryController.text = value;
                        setState(() {});
                      })
                    : results.isEmpty
                        ? Center(child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(s.searchEmpty, textAlign: TextAlign.center),
                          ))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
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

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onSelect});
  final ValueChanged<String> onSelect;

  static const _keywords = ['Widget', 'State', 'Navigator', 'Future', 'Layout', 'BuildContext', 'StreamBuilder'];

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.manage_search_rounded, size: 42, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 10),
        Text(s.searchHint, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
          for (final keyword in _keywords)
            ActionChip(label: Text(keyword), onPressed: () => onSelect(keyword)),
        ]),
      ]),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.question, required this.language, required this.showAnswers});

  final Question question;
  final ContentLanguage language;
  final bool showAnswers;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final scheme = Theme.of(context).colorScheme;
    final bookmark = context.watch<BookmarkController>();
    final saved = bookmark.isBookmarked(question.id);
    final options = question.optionsFor(language);
    return Card(
      color: scheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Chip(label: Text('${language == ContentLanguage.vi ? 'Khối' : 'Block'} ${question.blockId} · ${s.questionLabel(question.id)}')),
            const Spacer(),
            IconButton(
              tooltip: saved ? s.removeBookmark : s.bookmarkTooltip,
              icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: saved ? scheme.primary : null),
              onPressed: () => context.read<BookmarkController>().toggle(question.id),
            ),
          ]),
          Text(question.questionFor(language), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (var i = 0; i < options.length; i++)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: showAnswers && i == question.correctIndex
                  ? BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.withValues(alpha: 0.35)))
                  : null,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (showAnswers && i == question.correctIndex) ...[
                  const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(options[i], style: showAnswers && i == question.correctIndex
                    ? const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)
                    : null)),
              ]),
            ),
          if (showAnswers && question.explanationFor(language).trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.explanation, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(question.explanationFor(language)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
