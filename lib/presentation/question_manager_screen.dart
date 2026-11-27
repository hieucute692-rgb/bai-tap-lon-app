import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/json_subject_store.dart';
import '../domain/question.dart';
import 'question_bank_controller.dart';
import 'settings_controller.dart';

/// Màn 1: Danh sách môn (giống Drive trên điện thoại).
class QuestionManagerSubjectsScreen extends StatelessWidget {
  const QuestionManagerSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<QuestionBankController>();
    final s = context.watch<SettingsController>().strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.manageQuestions,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            tooltip: s.newSubject,
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _createSubjectDialog(context, c),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: c.currentSubject == null
          ? null
          : _GradientFab(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuestionFormScreen(
              subject: c.currentSubject!,
              initialQuestion: null,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 88),
            itemCount: c.subjects.length,
            itemBuilder: (context, index) {
              final sub = c.subjects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            QuestionManagerBlocksScreen(subject: sub),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? scheme.surfaceContainer : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFE8ECF7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: Colors.white, width: 1.2),
                            ),
                            child: const Icon(
                              Icons.folder_rounded,
                              color: Color(0xFF4F46E5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub.fileName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _createSubjectDialog(
      BuildContext context,
      QuestionBankController c,
      ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NewSubjectDialog(),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      await c.createSubject(name, switchToNew: false);
    }
  }
}

/// Màn 2: Chỉ hiển thị các mục lớn (block) trong môn.
class QuestionManagerBlocksScreen extends StatefulWidget {
  const QuestionManagerBlocksScreen({super.key, required this.subject});

  final SubjectItem subject;

  @override
  State<QuestionManagerBlocksScreen> createState() =>
      _QuestionManagerBlocksScreenState();
}

class _QuestionManagerBlocksScreenState
    extends State<QuestionManagerBlocksScreen> {
  late Future<List<Question>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future =
        context.read<QuestionBankController>().loadQuestionsFor(widget.subject);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>().strings;
    final lang = context.watch<SettingsController>().language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.subject.name} · ${s.blocksScreenTitle}',
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      floatingActionButton: _GradientFab(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => QuestionFormScreen(
                subject: widget.subject,
                initialQuestion: null,
              ),
            ),
          );
          _reload();
        },
      ),
      body: FutureBuilder<List<Question>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final questions = snap.data!;
          final map = <int, List<Question>>{};
          for (final q in questions) {
            map.putIfAbsent(q.blockId, () => []).add(q);
          }
          final blockIds = map.keys.toList()..sort();

          if (blockIds.isEmpty) {
            return Center(child: Text(s.noQuestions));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 88),
                itemCount: blockIds.length,
                itemBuilder: (context, i) {
                  final bId = blockIds[i];
                  final items = map[bId]!;
                  final first = items.first;
                  final title = s.blockTitle(bId, first.blockNameFor(lang));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => QuestionManagerQuestionsScreen(
                                subject: widget.subject,
                                blockId: bId,
                                blockTitle: title,
                              ),
                            ),
                          );
                          _reload();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                            isDark ? scheme.surfaceContainer : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFE8ECF7),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE3EEFF),
                                      Color(0xFFEDE9FE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  '$bId',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                    color: const Color(0xFF1E40AF),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.questionCount(items.length),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NewSubjectDialog extends StatefulWidget {
  const _NewSubjectDialog();

  @override
  State<_NewSubjectDialog> createState() => _NewSubjectDialogState();
}

class _NewSubjectDialogState extends State<_NewSubjectDialog> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<SettingsController>().strings;
    return AlertDialog(
      title: Text(s.newSubject),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(hintText: s.subjectName),
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) {
            Navigator.of(context).pop(trimmed);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.goBack),
        ),
        FilledButton(
          onPressed: () {
            final trimmed = _ctrl.text.trim();
            if (trimmed.isNotEmpty) {
              Navigator.of(context).pop(trimmed);
            }
          },
          child: Text(s.save),
        ),
      ],
    );
  }
}

/// Danh sách câu hỏi thuộc 1 khối lớn.
class QuestionManagerQuestionsScreen extends StatefulWidget {
  const QuestionManagerQuestionsScreen({
    super.key,
    required this.subject,
    required this.blockId,
    required this.blockTitle,
  });

  final SubjectItem subject;
  final int blockId;
  final String blockTitle;

  @override
  State<QuestionManagerQuestionsScreen> createState() =>
      _QuestionManagerQuestionsScreenState();
}

class _QuestionManagerQuestionsScreenState
    extends State<QuestionManagerQuestionsScreen> {
  late Future<List<Question>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future =
        context.read<QuestionBankController>().loadQuestionsFor(widget.subject);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>().strings;
    final lang = context.watch<SettingsController>().language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.blockTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      floatingActionButton: _GradientFab(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => QuestionFormScreen(
                subject: widget.subject,
                initialQuestion: null,
                defaultBlockId: widget.blockId,
              ),
            ),
          );
          _reload();
        },
      ),
      body: FutureBuilder<List<Question>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final filtered =
          snap.data!.where((q) => q.blockId == widget.blockId).toList();
          if (filtered.isEmpty) {
            return Center(child: Text(s.noQuestions));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 88),
                itemCount: filtered.length,
                itemBuilder: (context, idx) {
                  final q = filtered[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => QuestionFormScreen(
                                subject: widget.subject,
                                initialQuestion: q,
                              ),
                            ),
                          );
                          _reload();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                            isDark ? scheme.surfaceContainer : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFE8ECF7),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE3EEFF),
                                      Color(0xFFEDE9FE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '#${q.id}',
                                  style: const TextStyle(
                                    color: Color(0xFF1E40AF),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  q.questionFor(lang),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFDC2626),
                                ),
                                onPressed: () async {
                                  await context
                                      .read<QuestionBankController>()
                                      .deleteQuestion(widget.subject, q.id);
                                  _reload();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Màn 3: Form điền câu hỏi giống cấu trúc JSON + nút Lưu bật/tắt theo thay đổi.
class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({
    super.key,
    required this.subject,
    required this.initialQuestion,
    this.defaultBlockId = 1,
  });

  final SubjectItem subject;
  final Question? initialQuestion;
  final int defaultBlockId;

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _blockIdCtrl;
  late final TextEditingController _blockViCtrl;
  late final TextEditingController _blockEnCtrl;
  late final TextEditingController _qViCtrl;
  late final TextEditingController _qEnCtrl;
  late final List<TextEditingController> _optViCtrls;
  late final List<TextEditingController> _optEnCtrls;
  late final TextEditingController _expViCtrl;
  late final TextEditingController _expEnCtrl;
  late int _correctIndex;
  late String _initialSnapshot;
  bool _hasChanges = false;

  List<TextEditingController> get _allControllers => [
    _idCtrl,
    _blockIdCtrl,
    _blockViCtrl,
    _blockEnCtrl,
    _qViCtrl,
    _qEnCtrl,
    ..._optViCtrls,
    ..._optEnCtrls,
    _expViCtrl,
    _expEnCtrl,
  ];

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    _idCtrl = TextEditingController(
      text: '${q?.id ?? DateTime.now().millisecondsSinceEpoch % 100000}',
    );
    _blockIdCtrl = TextEditingController(
      text: '${q?.blockId ?? widget.defaultBlockId}',
    );
    _blockViCtrl = TextEditingController(text: q?.blockNameVi ?? '');
    _blockEnCtrl = TextEditingController(text: q?.blockNameEn ?? '');
    _qViCtrl = TextEditingController(text: q?.questionVi ?? '');
    _qEnCtrl = TextEditingController(text: q?.questionEn ?? '');
    _optViCtrls = List.generate(
      4,
          (i) => TextEditingController(text: q?.optionsVi[i] ?? ''),
    );
    _optEnCtrls = List.generate(
      4,
          (i) => TextEditingController(text: q?.optionsEn[i] ?? ''),
    );
    _expViCtrl = TextEditingController(text: q?.explanationVi ?? '');
    _expEnCtrl = TextEditingController(text: q?.explanationEn ?? '');
    _correctIndex = q?.correctIndex ?? 0;

    _initialSnapshot = _buildSnapshot();
    for (final c in _allControllers) {
      c.addListener(_recomputeDirty);
    }
  }

  String _buildSnapshot() {
    return [
      _idCtrl.text,
      _blockIdCtrl.text,
      _blockViCtrl.text,
      _blockEnCtrl.text,
      _qViCtrl.text,
      _qEnCtrl.text,
      ..._optViCtrls.map((e) => e.text),
      ..._optEnCtrls.map((e) => e.text),
      '$_correctIndex',
      _expViCtrl.text,
      _expEnCtrl.text,
    ].join('\u0000');
  }

  void _recomputeDirty() {
    final dirty = _buildSnapshot() != _initialSnapshot;
    if (dirty != _hasChanges) {
      setState(() => _hasChanges = dirty);
    }
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onSave() async {
    final s = context.read<SettingsController>().strings;
    final id = int.tryParse(_idCtrl.text.trim());
    final blockId = int.tryParse(_blockIdCtrl.text.trim());
    if (id == null || blockId == null) return;

    final question = Question(
      id: id,
      blockId: blockId,
      blockNameVi: _blockViCtrl.text.trim(),
      blockNameEn: _blockEnCtrl.text.trim(),
      questionVi: _qViCtrl.text,
      questionEn: _qEnCtrl.text,
      optionsVi: _optViCtrls.map((e) => e.text).toList(),
      optionsEn: _optEnCtrls.map((e) => e.text).toList(),
      correctIndex: _correctIndex,
      explanationVi: _expViCtrl.text,
      explanationEn: _expEnCtrl.text,
    );

    await context
        .read<QuestionBankController>()
        .upsertQuestion(widget.subject, question);

    _initialSnapshot = _buildSnapshot();
    setState(() => _hasChanges = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.savedSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>().strings;
    final isEdit = widget.initialQuestion != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEdit ? s.editQuestion : s.addQuestion,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: _hasChanges
                  ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              )
                  : null,
              color: _hasChanges
                  ? null
                  : (isDark
                  ? scheme.surfaceContainerHighest
                  : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _hasChanges ? _onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                s.save,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _hasChanges ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? scheme.surfaceContainer : Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                child: Column(
                  children: [
                    _field(
                      context,
                      _idCtrl,
                      s.questionIdLabel,
                      isNumber: true,
                    ),
                    _field(
                      context,
                      _blockIdCtrl,
                      s.blockIdLabel,
                      isNumber: true,
                    ),
                    _field(context, _blockViCtrl, s.blockNameViLabel),
                    _field(context, _blockEnCtrl, s.blockNameEnLabel),
                    _field(context, _qViCtrl, s.questionViLabel, maxLines: 4),
                    _field(context, _qEnCtrl, s.questionEnLabel, maxLines: 4),
                    for (var i = 0; i < 4; i++) ...[
                      _field(
                        context,
                        _optViCtrls[i],
                        'Đáp án ${String.fromCharCode(65 + i)} (VI)',
                        maxLines: null,
                      ),
                      _field(
                        context,
                        _optEnCtrls[i],
                        'Option ${String.fromCharCode(65 + i)} (EN)',
                        maxLines: null,
                      ),
                    ],
                    DropdownButtonFormField<int>(
                      initialValue: _correctIndex,
                      decoration: InputDecoration(
                        labelText: s.correctIndexLabel,
                        filled: true,
                        fillColor: isDark
                            ? scheme.surfaceContainerHigh
                            : const Color(0xFFF6F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [0, 1, 2, 3]
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text('$v')),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _correctIndex = val);
                        _recomputeDirty();
                      },
                    ),
                    const SizedBox(height: 12),
                    _field(
                      context,
                      _expViCtrl,
                      s.explanationViLabel,
                      maxLines: null,
                      minLines: 4,
                    ),
                    _field(
                      context,
                      _expEnCtrl,
                      s.explanationEnLabel,
                      maxLines: null,
                      minLines: 4,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      BuildContext context,
      TextEditingController ctrl,
      String label, {
        int? maxLines = 1,
        int? minLines,
        bool isNumber = false,
        bool isLast = false,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        minLines: minLines ?? (maxLines == null ? 2 : null),
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint:
          maxLines == null || (maxLines != null && maxLines > 1),
          filled: true,
          fillColor:
          isDark ? scheme.surfaceContainerHigh : const Color(0xFFF6F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}