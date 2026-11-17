/// Thời gian làm bài mặc định: 90 giây mỗi câu (30 câu = 45 phút).
Duration defaultExamDuration(int questionCount) =>
    Duration(seconds: questionCount * 90);

/// Đồng hồ đếm ngược tính theo giờ hệ thống (hạn chót cố định), không đếm bằng số lần
/// Timer chạy. Nhờ vậy khi app bị đưa xuống nền rồi quay lại, thời gian vẫn đúng.
class ExamCountdown {
  ExamCountdown({required this.duration, required DateTime startedAt})
      : deadline = startedAt.add(duration);

  final Duration duration;
  final DateTime deadline;

  /// Ngưỡng cảnh báo sắp hết giờ: 5 phút cuối, hoặc 1/5 tổng thời gian nếu bài ngắn hơn.
  Duration get warningThreshold {
    final fifth = Duration(milliseconds: duration.inMilliseconds ~/ 5);
    const fiveMinutes = Duration(minutes: 5);
    return fifth < fiveMinutes ? fifth : fiveMinutes;
  }

  Duration remaining(DateTime now) {
    final r = deadline.difference(now);
    return r.isNegative ? Duration.zero : r;
  }

  bool isExpired(DateTime now) => !now.isBefore(deadline);

  bool isWarning(DateTime now) =>
      !isExpired(now) && remaining(now) <= warningThreshold;

  /// "mm:ss", hoặc "h:mm:ss" từ một giờ trở lên. Làm tròn lên để chỉ hiện 00:00 khi hết giờ.
  static String format(Duration d) {
    final total = (d.inMilliseconds / 1000).ceil();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
}
