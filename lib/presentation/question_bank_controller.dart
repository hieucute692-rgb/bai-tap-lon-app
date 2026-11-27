import 'package:flutter/foundation.dart';

import '../data/json_subject_store.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';

enum LoadStatus { loading, ready, error }

class QuestionBankController extends ChangeNotifier {
  QuestionBankController(
      this._store, {
        this.onSubjectChanged,
      });

  final JsonSubjectStore _store;
  final Future<void> Function(String subjectId)? onSubjectChanged;

  LoadStatus _status = LoadStatus.loading;
  QuestionBank? _bank;
  String? _errorMessage;
  List<SubjectItem> _subjects = const [];
  SubjectItem? _currentSubject;
  bool _disposed = false;

  LoadStatus get status => _status;
  QuestionBank? get bank => _bank;
  String? get errorMessage => _errorMessage;
  List<SubjectItem> get subjects => _subjects;
  SubjectItem? get currentSubject => _currentSubject;

  Future<void> load({SubjectItem? targetSubject}) async {
    final wasLoading = _status == LoadStatus.loading;
    _status = LoadStatus.loading;
    _errorMessage = null;
    if (!wasLoading) notifyListeners();

    try {
      _subjects = await _store.ensureInitialized();
      _currentSubject = targetSubject ??
          _currentSubject ??
          (_subjects.isNotEmpty ? _subjects.first : null);
      if (_currentSubject != null) {
        await onSubjectChanged?.call(_currentSubject!.id);
        if (_disposed) return;
        _bank = await _store.loadBank(_currentSubject!);
      } else {
        _bank = QuestionBank([]);
      }
      _status = LoadStatus.ready;
    } catch (e, st) {
      debugPrint('Không nạp được ngân hàng câu hỏi: $e\n$st');
      _errorMessage = 'Không tải được ngân hàng câu hỏi.';
      _status = LoadStatus.error;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> selectSubject(SubjectItem subject) async {
    await load(targetSubject: subject);
  }

  Future<void> createSubject(String name, {bool switchToNew = true}) async {
    final created = await _store.createSubject(name);
    _subjects = await _store.ensureInitialized();
    if (switchToNew) {
      await load(targetSubject: created);
    } else if (!_disposed) {
      notifyListeners();
    }
  }

  Future<List<Question>> loadQuestionsFor(SubjectItem subject) {
    return _store.loadQuestions(subject);
  }

  Future<void> upsertQuestion(SubjectItem subject, Question question) async {
    final current = List<Question>.from(await _store.loadQuestions(subject));
    final idx = current.indexWhere((q) => q.id == question.id);
    if (idx >= 0) {
      current[idx] = question;
    } else {
      current.add(question);
    }
    await _store.saveQuestions(subject, current);
    if (_currentSubject?.id == subject.id) {
      _bank = QuestionBank(current);
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> deleteQuestion(SubjectItem subject, int questionId) async {
    final current = List<Question>.from(await _store.loadQuestions(subject));
    current.removeWhere((q) => q.id == questionId);
    await _store.saveQuestions(subject, current);
    if (_currentSubject?.id == subject.id) {
      _bank = QuestionBank(current);
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}