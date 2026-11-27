import 'subject_storage_io.dart'
if (dart.library.html) 'subject_storage_web.dart';

abstract class SubjectStorageBackend {
  Future<bool> exists(String key);
  Future<String?> readString(String key);
  Future<void> writeString(String key, String content);
}

SubjectStorageBackend createSubjectStorageBackend() => createBackend();