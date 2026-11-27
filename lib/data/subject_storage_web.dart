import 'package:shared_preferences/shared_preferences.dart';

import 'subject_storage_backend.dart';

SubjectStorageBackend createBackend() => _WebSubjectStorageBackend();

class _WebSubjectStorageBackend implements SubjectStorageBackend {
  static const _prefix = 'web_subject_store_v1_';

  String _storageKey(String key) => '$_prefix$key';

  @override
  Future<bool> exists(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_storageKey(key));
  }

  @override
  Future<String?> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKey(key));
  }

  @override
  Future<void> writeString(String key, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(key), content);
  }
}