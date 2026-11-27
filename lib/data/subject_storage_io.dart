import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'subject_storage_backend.dart';

SubjectStorageBackend createBackend() => _IoSubjectStorageBackend();

class _IoSubjectStorageBackend implements SubjectStorageBackend {
  Future<Directory> _subjectsDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docDir.path}/subjects');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _fileFor(String key) async {
    final dir = await _subjectsDir();
    return File('${dir.path}/$key');
  }

  @override
  Future<bool> exists(String key) async {
    final file = await _fileFor(key);
    return file.exists();
  }

  @override
  Future<String?> readString(String key) async {
    final file = await _fileFor(key);
    if (!await file.exists()) return null;
    return file.readAsString(encoding: utf8);
  }

  @override
  Future<void> writeString(String key, String content) async {
    final file = await _fileFor(key);
    await file.writeAsString(content, encoding: utf8);
  }
}