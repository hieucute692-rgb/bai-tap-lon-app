import 'package:flutter_quiz_300/domain/exam_countdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 1, 1, 8);

  test('thời gian mặc định 90 giây mỗi câu', () {
    expect(defaultExamDuration(30), const Duration(minutes: 45));
    expect(defaultExamDuration(10), const Duration(minutes: 15));
  });

  test('thời gian còn lại giảm dần và không âm', () {
    final c = ExamCountdown(duration: const Duration(minutes: 10), startedAt: start);
    expect(c.remaining(start), const Duration(minutes: 10));
    expect(c.remaining(start.add(const Duration(minutes: 4))), const Duration(minutes: 6));
    expect(c.remaining(start.add(const Duration(minutes: 11))), Duration.zero);
  });

  test('hết giờ đúng tại hạn chót', () {
    final c = ExamCountdown(duration: const Duration(minutes: 10), startedAt: start);
    expect(c.isExpired(start.add(const Duration(minutes: 10) - const Duration(seconds: 1))), isFalse);
    expect(c.isExpired(start.add(const Duration(minutes: 10))), isTrue);
  });

  test('ngưỡng cảnh báo: 5 phút, hoặc 1/5 thời gian nếu bài ngắn hơn', () {
    expect(
      ExamCountdown(duration: const Duration(minutes: 45), startedAt: start).warningThreshold,
      const Duration(minutes: 5),
    );
    expect(
      ExamCountdown(duration: const Duration(minutes: 10), startedAt: start).warningThreshold,
      const Duration(minutes: 2),
    );
  });

  test('cảnh báo khi còn trong ngưỡng và chưa hết giờ', () {
    final c = ExamCountdown(duration: const Duration(minutes: 45), startedAt: start);
    expect(c.isWarning(start.add(const Duration(minutes: 39))), isFalse); // còn 6 phút
    expect(c.isWarning(start.add(const Duration(minutes: 41))), isTrue); // còn 4 phút
    expect(c.isWarning(start.add(const Duration(minutes: 45))), isFalse); // đã hết giờ
  });

  test('định dạng mm:ss và h:mm:ss, làm tròn lên', () {
    expect(ExamCountdown.format(const Duration(minutes: 45)), '45:00');
    expect(ExamCountdown.format(Duration.zero), '00:00');
    expect(ExamCountdown.format(const Duration(milliseconds: 59500)), '01:00');
    expect(ExamCountdown.format(const Duration(hours: 1, minutes: 5)), '1:05:00');
  });
}
