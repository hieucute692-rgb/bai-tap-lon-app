import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/bookmark_repository.dart';

/// Lưu các câu đã đánh dấu trên máy bằng shared_preferences. Dữ liệu hỏng thì coi như chưa có.
class SharedPrefsBookmarkRepository implements BookmarkRepository {
  SharedPrefsBookmarkRepository({String subjectId = defaultSubjectId})
      : _subjectId = _sanitizeSubjectId(subjectId);

  static const String defaultSubjectId = 'flutter_review';
  static const String _keyPrefix = 'bookmarks_v1_';

  String _subjectId;

  String get subjectId => _subjectId;

  static String _sanitizeSubjectId(String id) {
    final cleaned = id.trim();
    return cleaned.isEmpty ? defaultSubjectId : cleaned;
  }

  String get _key => '$_keyPrefix$_subjectId';

  void setSubject(String subjectId) {
    _subjectId = _sanitizeSubjectId(subjectId);
  }

  @override
  Future<Set<int>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return <int>{};
    try {
      final list = jsonDecode(raw) as List;
      return <int>{for (final e in list) e as int};
    } catch (e) {
      debugPrint('Danh sách đánh dấu bị hỏng, bỏ qua: $e');
      return <int>{};
    }
  }

  @override
  Future<void> saveBookmarks(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ids.toList()..sort()));
  }
}