import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'asset_question_repository.dart';
import 'subject_storage_backend.dart';

class SubjectItem {
  const SubjectItem({
    required this.id,
    required this.name,
    required this.fileName,
  });

  final String id;
  final String name;
  final String fileName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fileName': fileName,
  };

  factory SubjectItem.fromJson(Map<String, dynamic> json) => SubjectItem(
    id: json['id'] as String,
    name: json['name'] as String,
    fileName: json['fileName'] as String,
  );
}

class JsonSubjectStore {
  JsonSubjectStore({
    AssetBundle? bundle,
    SubjectStorageBackend? storage,
  })  : _bundle = bundle ?? rootBundle,
        _storage = storage ?? createSubjectStorageBackend();

  final AssetBundle _bundle;
  final SubjectStorageBackend _storage;

  static const _defaultSubjectId = 'flutter_review';
  static const _metaKey = '_subjects_meta.json';

  String _slugifyFileName(String raw) {
    final cleaned = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final base = cleaned.isEmpty ? 'subject' : cleaned;
    return '${base}_${DateTime.now().millisecondsSinceEpoch}.json';
  }

  Future<List<SubjectItem>> ensureInitialized() async {
    const defaultJsonKey = 'flutter_review.json';

    if (!await _storage.exists(defaultJsonKey)) {
      final rawAsset =
      await _bundle.loadString(AssetQuestionRepository.defaultAssetPath);
      await _storage.writeString(defaultJsonKey, rawAsset);
    }

    if (!await _storage.exists(_metaKey)) {
      final initial = [
        const SubjectItem(
          id: _defaultSubjectId,
          name: 'Ôn tập Flutter',
          fileName: defaultJsonKey,
        ),
      ];
      await _storage.writeString(
        _metaKey,
        jsonEncode(initial.map((e) => e.toJson()).toList()),
      );
      return initial;
    }

    final rawMeta = await _storage.readString(_metaKey);
    if (rawMeta == null || rawMeta.trim().isEmpty) return const [];
    final list = jsonDecode(rawMeta) as List<dynamic>;
    return list
        .map((e) => SubjectItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubjectItem> createSubject(String name) async {
    final subjects = await ensureInitialized();
    final fileName = _slugifyFileName(name);
    final item = SubjectItem(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      fileName: fileName,
    );
    await _storage.writeString(fileName, '[]');

    final updated = [...subjects, item];
    await _storage.writeString(
      _metaKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    return item;
  }

  Future<List<Question>> loadQuestions(SubjectItem subject) async {
    if (!await _storage.exists(subject.fileName)) {
      await _storage.writeString(subject.fileName, '[]');
      return const [];
    }
    final content = await _storage.readString(subject.fileName);
    if (content == null || content.trim().isEmpty) return const [];
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('File JSON môn học phải là một mảng');
    }
    return decoded
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveQuestions(
      SubjectItem subject,
      List<Question> questions,
      ) async {
    const encoder = JsonEncoder.withIndent('  ');
    final payload = questions.map((q) => q.toJson()).toList();
    await _storage.writeString(subject.fileName, encoder.convert(payload));
  }

  Future<QuestionBank> loadBank(SubjectItem subject) async {
    final questions = await loadQuestions(subject);
    return QuestionBank(questions);
  }
}