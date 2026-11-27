import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'asset_question_repository.dart';

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
  JsonSubjectStore({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const _defaultSubjectId = 'flutter_review';

  Future<Directory> _subjectsDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docDir.path}/subjects');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _metaFile() async {
    final dir = await _subjectsDir();
    return File('${dir.path}/_subjects_meta.json');
  }

  Future<File> _questionFile(String fileName) async {
    final dir = await _subjectsDir();
    return File('${dir.path}/$fileName');
  }

  String _slugifyFileName(String raw) {
    final cleaned = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final base = cleaned.isEmpty ? 'subject' : cleaned;
    return '${base}_${DateTime.now().millisecondsSinceEpoch}.json';
  }

  Future<List<SubjectItem>> ensureInitialized() async {
    final meta = await _metaFile();
    final defaultJsonFile = await _questionFile('flutter_review.json');

    if (!await defaultJsonFile.exists()) {
      final rawAsset =
      await _bundle.loadString(AssetQuestionRepository.defaultAssetPath);
      await defaultJsonFile.writeAsString(rawAsset, encoding: utf8);
    }

    if (!await meta.exists()) {
      final initial = [
        const SubjectItem(
          id: _defaultSubjectId,
          name: 'Ôn tập Flutter',
          fileName: 'flutter_review.json',
        ),
      ];
      await meta.writeAsString(
        jsonEncode(initial.map((e) => e.toJson()).toList()),
        encoding: utf8,
      );
      return initial;
    }

    final rawMeta = await meta.readAsString(encoding: utf8);
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
    final qFile = await _questionFile(fileName);
    await qFile.writeAsString('[]', encoding: utf8);

    final updated = [...subjects, item];
    final meta = await _metaFile();
    await meta.writeAsString(
      jsonEncode(updated.map((e) => e.toJson()).toList()),
      encoding: utf8,
    );
    return item;
  }

  Future<List<Question>> loadQuestions(SubjectItem subject) async {
    final file = await _questionFile(subject.fileName);
    if (!await file.exists()) {
      await file.writeAsString('[]', encoding: utf8);
      return const [];
    }
    final content = await file.readAsString(encoding: utf8);
    if (content.trim().isEmpty) return const [];
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('File JSON môn học phải là một mảng');
    }
    return decoded
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveQuestions(SubjectItem subject, List<Question> questions) async {
    final file = await _questionFile(subject.fileName);
    const encoder = JsonEncoder.withIndent('  ');
    final payload = questions.map((q) => q.toJson()).toList();
    await file.writeAsString(encoder.convert(payload), encoding: utf8);
  }

  Future<QuestionBank> loadBank(SubjectItem subject) async {
    final questions = await loadQuestions(subject);
    return QuestionBank(questions);
  }
}