import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/progress.dart';
import '../domain/progress_repository.dart';

/// Lưu tiến độ trên máy bằng shared_preferences (chạy được cả Android và web).
/// Dữ liệu hỏng sẽ bị bỏ qua thay vì làm app dừng.
class SharedPrefsProgressRepository implements ProgressRepository {
  static const statsKey = 'progress_stats_v1';
  static const examsKey = 'progress_exams_v1';

  @override
  Future<Map<int, QuestionStat>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(statsKey);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw) as List;
      final stats = list.map((e) => QuestionStat.fromJson(e as Map<String, dynamic>));
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
    await prefs.setString(statsKey, encoded);
  }

  @override
  Future<List<ExamResult>> loadExamResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(examsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ExamResult.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Lịch sử thi thử bị hỏng, bỏ qua: $e');
      return [];
    }
  }

  @override
  Future<void> saveExamResults(List<ExamResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      examsKey,
      jsonEncode(results.map((r) => r.toJson()).toList()),
    );
  }
}
