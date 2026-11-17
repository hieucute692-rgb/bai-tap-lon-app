import 'progress.dart';

/// Nơi lưu tiến độ làm bài. Dữ liệu nhỏ (tối đa 300 câu + vài chục lần thi)
/// nên ghi trọn bộ mỗi lần, không cần cơ sở dữ liệu quan hệ.
abstract class ProgressRepository {
  Future<Map<int, QuestionStat>> loadStats();
  Future<void> saveStats(Map<int, QuestionStat> stats);
  Future<List<ExamResult>> loadExamResults();
  Future<void> saveExamResults(List<ExamResult> results);
}
