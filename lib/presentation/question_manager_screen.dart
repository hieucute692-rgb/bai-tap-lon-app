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

    return Scaffold(
      appBar: AppBar(
        title: Text(s.manageQuestions),
        actions: [
          IconButton(
            tooltip: s.newSubject,
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _createSubjectDialog(context, c),
          ),
        ],
      ),
      floatingActionButton: c.currentSubject == null
          ? null
          : FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuestionFormScreen(
              subject: c.currentSubject!,
              initialQuestion: null,
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: c.subjects.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sub = c.subjects[index];
          return ListTile(
            leading: const Icon(Icons.folder_rounded),
            title: Text(sub.name),
            subtitle: Text(sub.fileName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => QuestionManagerBlocksScreen(subject: sub),
              ),
            ),
          );
        },
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
    _future = context.read<QuestionBankController>().loadQuestionsFor(widget.subject);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>().strings;
    final lang = context.watch<SettingsController>().language;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.name} · ${s.blocksScreenTitle}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
        child: const Icon(Icons.add),
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

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: blockIds.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final bId = blockIds[i];
              final items = map[bId]!;
              final first = items.first;
              final title = s.blockTitle(bId, first.blockNameFor(lang));
              return ListTile(
                leading: CircleAvatar(child: Text('$bId')),
                title: Text(title),
                subtitle: Text(s.questionCount(items.length)),
                trailing: const Icon(Icons.chevron_right),
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
              );
            },
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
    _future = context.read<QuestionBankController>().loadQuestionsFor(widget.subject);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>().strings;
    final lang = context.watch<SettingsController>().language;

    return Scaffold(
      appBar: AppBar(title: Text(widget.blockTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
        child: const Icon(Icons.add),
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
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final q = filtered[idx];
              return ListTile(
                leading: Text('#${q.id}'),
                title: Text(
                  q.questionFor(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context
                        .read<QuestionBankController>()
                        .deleteQuestion(widget.subject, q.id);
                    _reload();
                  },
                ),
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
              );
            },
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? s.editQuestion : s.addQuestion),
        actions: [
          FilledButton(
            onPressed: _hasChanges ? _onSave : null,
            child: Text(s.save),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_idCtrl, s.questionIdLabel, isNumber: true),
          _field(_blockIdCtrl, s.blockIdLabel, isNumber: true),
          _field(_blockViCtrl, s.blockNameViLabel),
          _field(_blockEnCtrl, s.blockNameEnLabel),
          _field(_qViCtrl, s.questionViLabel, maxLines: 4),
          _field(_qEnCtrl, s.questionEnLabel, maxLines: 4),
          for (var i = 0; i < 4; i++) ...[
            _field(
              _optViCtrls[i],
              'Đáp án ${String.fromCharCode(65 + i)} (VI)',
              maxLines: null,
            ),
            _field(
              _optEnCtrls[i],
              'Option ${String.fromCharCode(65 + i)} (EN)',
              maxLines: null,
            ),
          ],
          DropdownButtonFormField<int>(
            initialValue: _correctIndex,
            decoration: InputDecoration(labelText: s.correctIndexLabel),
            items: const [0, 1, 2, 3]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() => _correctIndex = val);
              _recomputeDirty();
            },
          ),
          const SizedBox(height: 12),
          _field(
            _expViCtrl,
            s.explanationViLabel,
            maxLines: null,
            minLines: 4,
          ),
          _field(
            _expEnCtrl,
            s.explanationEnLabel,
            maxLines: null,
            minLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        int? maxLines = 1,
        int? minLines,
        bool isNumber = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        minLines: minLines ?? (maxLines == null ? 2 : null),
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines == null || (maxLines != null && maxLines > 1),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}