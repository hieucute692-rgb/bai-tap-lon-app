import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/progress.dart';
import '../domain/progress_repository.dart';
import '../domain/daily_study.dart';
import '../domain/daily_study_repository.dart';
import 'question_bank_controller.dart';
import '../data/shared_prefs_progress_repository.dart';

/// Loại sự cố khi đọc/ghi tiến độ; giao diện tự đổi thành câu chữ theo ngôn ngữ.
enum ProgressProblem { loadFailed, saveFailed }

/// Giữ tiến độ làm bài trong bộ nhớ và ghi xuống máy. Lỗi đọc/ghi không làm app dừng:
/// app vẫn dùng được và [problem] cho giao diện biết để báo người dùng.
class ProgressController extends ChangeNotifier {
  ProgressController(
    this._repository, {
    DateTime Function()? clock,
    DailyStudyRepository? dailyStudyRepository,
  })  : _clock = clock ?? DateTime.now,
        _dailyStudyRepository = dailyStudyRepository {
    _daily = DailyStudyData(todayDate: _dateKey(_clock()));
    _dailyLoaded = dailyStudyRepository == null;
    _scheduleDailyRollover();
  }

  static const maxExamHistory = 20;

  final ProgressRepository _repository;
  final DateTime Function() _clock;
  final DailyStudyRepository? _dailyStudyRepository;

  late DailyStudyData _daily;
  bool _dailyLoaded = false;
  Future<void>? _dailyLoadFuture;

  LoadStatus _status = LoadStatus.loading;
  Map<int, QuestionStat> _stats = {};
  List<ExamResult> _exams = [];
  ProgressProblem? _problem;
  bool _disposed = false;

  LoadStatus get status => _status;
  Map<int, QuestionStat> get stats => Map.unmodifiable(_stats);
  List<ExamResult> get examResults => List.unmodifiable(_exams);
  ProgressProblem? get problem => _problem;
  int get dailyGoal => _daily.dailyGoal;
  int get todayAnsweredCount => _daily.todayAnsweredCount;
  int get currentStreak => _daily.currentStreak;
  bool get dailyGoalComplete => todayAnsweredCount >= dailyGoal;

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
    await _ensureDailyStudyLoaded();
    _status = LoadStatus.ready;
    _notify();
  }

  Future<void> setSubject(String subjectId) async {
    if (_repository is SharedPrefsProgressRepository) {
      final repo = _repository as SharedPrefsProgressRepository;
      if (repo.subjectId == subjectId && _status == LoadStatus.ready) return;
      repo.setSubject(subjectId);
    }
    _status = LoadStatus.loading;
    _stats = {};
    _exams = [];
    _problem = null;
    _notify();
    await load();
  }
  /// Ghi kết quả các câu vừa làm (mã câu -> đúng/sai).
  Future<void> recordAnswers(
    Map<int, bool> outcomes, {
    int? activityCount,
  }) async {
    await _recordDailyActivity(activityCount ?? outcomes.length);
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

  Future<void> setDailyGoal(int goal) async {
    if (goal <= 0) return;
    final clampedGoal = goal.clamp(1, 999);
    await _ensureDailyStudyLoaded();
    if (clampedGoal == _daily.dailyGoal) return;
    _daily = DailyStudyData(
      dailyGoal: clampedGoal,
      todayAnsweredCount: _daily.todayAnsweredCount,
      todayDate: _daily.todayDate,
      currentStreak: _daily.currentStreak,
      lastStudyDate: _daily.lastStudyDate,
    );
    _notify();
    await _saveDailyStudy();
  }

  Future<void> _ensureDailyStudyLoaded() =>
      _dailyLoaded ? Future<void>.value() : (_dailyLoadFuture ??= _loadDailyStudy());

  Future<void> _loadDailyStudy() async {
    try {
      final saved = await _dailyStudyRepository!.loadDailyStudy();
      if (saved != null) _daily = saved;
    } catch (error, stackTrace) {
      debugPrint('Could not load daily study data: $error\n$stackTrace');
    }
    _daily = _normalizedDailyStudy(_daily, _clock());
    _dailyLoaded = true;
    _dailyLoadFuture = null;
    await _saveDailyStudy();
  }

  Future<void> _recordDailyActivity(int count) async {
    if (count <= 0) return;
    await _ensureDailyStudyLoaded();
    final today = _dateKey(_clock());
    final normalized = _normalizedDailyStudy(_daily, _clock());
    final difference = _daysBetween(normalized.lastStudyDate, today);
    final nextStreak = switch (difference) {
      null => 1,
      0 => normalized.currentStreak == 0 ? 1 : normalized.currentStreak,
      1 => normalized.currentStreak + 1,
      _ => 1,
    };
    _daily = DailyStudyData(
      dailyGoal: normalized.dailyGoal,
      todayAnsweredCount: normalized.todayAnsweredCount + count,
      todayDate: today,
      currentStreak: nextStreak,
      lastStudyDate: today,
    );
    _notify();
    await _saveDailyStudy();
  }

  DailyStudyData _normalizedDailyStudy(DailyStudyData data, DateTime now) {
    final today = _dateKey(now);
    final difference = _daysBetween(data.lastStudyDate, today);
    final hasInvalidLastDate = data.lastStudyDate != null && difference == null;
    final validGoal = data.dailyGoal > 0 ? data.dailyGoal.clamp(1, 999) : 15;
    return DailyStudyData(
      dailyGoal: validGoal,
      todayAnsweredCount:
      data.todayDate == today ? data.todayAnsweredCount : 0,
      todayDate: today,
      currentStreak:
      hasInvalidLastDate || (difference != null && difference > 1)
          ? 0
          : data.currentStreak,
      lastStudyDate: hasInvalidLastDate ? null : data.lastStudyDate,
    );
  }

  Future<void> _saveDailyStudy() async {
    final repository = _dailyStudyRepository;
    if (repository == null) return;
    try {
      await repository.saveDailyStudy(_daily);
    } catch (error, stackTrace) {
      debugPrint('Could not save daily study data: $error\n$stackTrace');
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static int? _daysBetween(String? previousDate, String today) {
    if (previousDate == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(previousDate)) {
      return null;
    }
    try {
      final previous = DateTime.parse('${previousDate}T00:00:00Z');
      final current = DateTime.parse('${today}T00:00:00Z');
      return current.difference(previous).inDays;
    } on FormatException {
      return null;
    }
  }

  void _scheduleDailyRollover() {
    _dailyRolloverTimer?.cancel();
    final now = _clock();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _dailyRolloverTimer = Timer(tomorrow.difference(now), () {
      final normalized = _normalizedDailyStudy(_daily, _clock());
      final changed = normalized.todayDate != _daily.todayDate ||
          normalized.todayAnsweredCount != _daily.todayAnsweredCount ||
          normalized.currentStreak != _daily.currentStreak;
      _daily = normalized;
      if (changed) {
        _notify();
        unawaited(_saveDailyStudy());
      }
      _scheduleDailyRollover();
    });
  }

  Timer? _dailyRolloverTimer;

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
    _dailyRolloverTimer?.cancel();
    super.dispose();
  }
}
