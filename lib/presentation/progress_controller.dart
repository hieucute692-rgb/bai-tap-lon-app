import 'package:flutter/foundation.dart';

import '../domain/progress.dart';
import '../domain/progress_repository.dart';
import 'question_bank_controller.dart';

/// Loại sự cố khi đọc/ghi tiến độ; giao diện tự đổi thành câu chữ theo ngôn ngữ.
enum ProgressProblem { loadFailed, saveFailed }

/// Giữ tiến độ làm bài trong bộ nhớ và ghi xuống máy. Lỗi đọc/ghi không làm app dừng:
/// app vẫn dùng được và [problem] cho giao diện biết để báo người dùng.
class ProgressController extends ChangeNotifier {
  ProgressController(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  static const maxExamHistory = 20;

  final ProgressRepository _repository;
  final DateTime Function() _clock;

  LoadStatus _status = LoadStatus.loading;
  Map<int, QuestionStat> _stats = {};
  List<ExamResult> _exams = [];
  ProgressProblem? _problem;
  bool _disposed = false;

  LoadStatus get status => _status;
  Map<int, QuestionStat> get stats => Map.unmodifiable(_stats);
  List<ExamResult> get examResults => List.unmodifiable(_exams);
  ProgressProblem? get problem => _problem;

  Future<void> load() async {
    try {
      _stats = await _repository.loadStats();
      _exams = await _repository.loadExamResults();
      _problem = null;
    } catch (e, st) {
      debugPrint('Không đọc được tiến độ: $e\n$st');
      _stats = {};
      _exams = [];
      _problem = ProgressProblem.loadFailed;
    }
    _status = LoadStatus.ready;
    _notify();
  }

  /// Ghi kết quả các câu vừa làm (mã câu -> đúng/sai).
  Future<void> recordAnswers(Map<int, bool> outcomes) async {
    final now = _clock();
    final next = Map<int, QuestionStat>.of(_stats);
    outcomes.forEach((id, isCorrect) {
      final old = next[id];
      next[id] = old == null
          ? QuestionStat(
              questionId: id,
              attempts: 1,
              correct: isCorrect ? 1 : 0,
              lastCorrect: isCorrect,
              lastAt: now,
            )
          : old.afterAnswer(isCorrect: isCorrect, at: now);
    });
    _stats = next;
    _notify();
    try {
      await _repository.saveStats(_stats);
    } catch (e, st) {
      debugPrint('Không lưu được tiến độ: $e\n$st');
      _problem = ProgressProblem.saveFailed;
      _notify();
    }
  }

  Future<void> addExamResult(ExamResult result) async {
    _exams = [result, ..._exams].take(maxExamHistory).toList();
    _notify();
    try {
      await _repository.saveExamResults(_exams);
    } catch (e, st) {
      debugPrint('Không lưu được lịch sử thi thử: $e\n$st');
      _problem = ProgressProblem.saveFailed;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
