import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/progress.dart';
import '../domain/progress_repository.dart';

class SharedPrefsProgressRepository implements ProgressRepository {
  SharedPrefsProgressRepository({String subjectId = defaultSubjectId})
      : _subjectId = _sanitizeSubjectId(subjectId);

  static const String defaultSubjectId = 'flutter_review';
  static const String _statsPrefix = 'progress_stats_v1_';
  static const String _examsPrefix = 'progress_exams_v1_';

  String _subjectId;

  String get subjectId => _subjectId;

  static String _sanitizeSubjectId(String id) {
    final cleaned = id.trim();
    return cleaned.isEmpty ? defaultSubjectId : cleaned;
  }

  String get _statsKey => '$_statsPrefix$_subjectId';
  String get _examsKey => '$_examsPrefix$_subjectId';

  void setSubject(String subjectId) {
    _subjectId = _sanitizeSubjectId(subjectId);
  }

  @override
  Future<Map<int, QuestionStat>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw) as List;
      final stats =
      list.map((e) => QuestionStat.fromJson(e as Map<String, dynamic>));
      return {for (final s in stats) s.questionId: s};
    } catch (e) {
      debugPrint('Dữ liệu tiến độ bị hỏng, bỏ qua: $e');
      return {};
    }
  }

  @override
  Future<void> saveStats(Map<int, QuestionStat> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(stats.values.map((s) => s.toJson()).toList());
    await prefs.setString(_statsKey, encoded);
  }

  @override
  Future<List<ExamResult>> loadExamResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_examsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Lịch sử thi thử bị hỏng, bỏ qua: $e');
      return [];
    }
  }

  @override
  Future<void> saveExamResults(List<ExamResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _examsKey,
      jsonEncode(results.map((r) => r.toJson()).toList()),
    );
  }
}