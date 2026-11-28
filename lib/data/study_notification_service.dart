import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Quản lý thông báo nhắc hoàn thành chỉ tiêu trong ngày & giữ chuỗi học (streak).
class StudyNotificationService {
  StudyNotificationService._();

  static final StudyNotificationService instance = StudyNotificationService._();

  static const int _noonNotificationId = 1001;
  static const int _eveningNotificationId = 1002;
  static const int _testNotificationId = 9999;

  static const String _channelId = 'daily_study_reminder_channel';
  static const String _channelName = 'Nhắc chỉ tiêu học mỗi ngày';
  static const String _channelDescription =
      'Thông báo nhắc hoàn thành số câu hỏi trong ngày để tránh mất chuỗi';

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Khởi tạo plugin thông báo và múi giờ thiết bị.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      // Mặc định dùng múi giờ Việt Nam nếu thiết bị không trả về tên IANA chuẩn
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    // Tạo NotificationChannel trên Android
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  /// Xin quyền thông báo trên Android 13+.
  Future<bool> requestPermissionIfNeeded() async {
    await init();
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? true;
  }

  NotificationDetails _buildNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  /// Lên lịch 2 lần mỗi ngày:
  /// - 12:00 trưa: nhắc tranh thủ làm chỉ tiêu trong ngày
  /// - 20:30 tối: nhắc hoàn thành trước khi sang ngày mới để không mất chuỗi
  Future<void> scheduleDailyReminders({
    required int dailyGoal,
    required int todayAnsweredCount,
    required int currentStreak,
    required bool isVietnamese,
  }) async {
    await init();
    final remaining = (dailyGoal - todayAnsweredCount).clamp(0, dailyGoal);

    final String noonTitle;
    final String noonBody;
    final String eveningTitle;
    final String eveningBody;

    if (isVietnamese) {
      noonTitle = 'Nhắc chỉ tiêu học trưa nay';
      noonBody = remaining > 0
          ? 'Hôm nay bạn còn $remaining/$dailyGoal câu để đạt chỉ tiêu. Làm sớm cho nhẹ đầu nhé!'
          : 'Tuyệt vời! Bạn đã hoàn thành chỉ tiêu $dailyGoal câu hôm nay.';

      eveningTitle = 'Cảnh báo giữ chuỗi học (${currentStreak} ngày)!';
      eveningBody = remaining > 0
          ? 'Còn $remaining câu nữa mới đạt chỉ tiêu $dailyGoal câu/ngày — hoàn thành ngay để không bị mất chuỗi!'
          : 'Bạn đã đạt chỉ tiêu hôm nay và giữ vững chuỗi $currentStreak ngày!';
    } else {
      noonTitle = 'Midday daily goal check-in';
      noonBody = remaining > 0
          ? 'You still have $remaining/$dailyGoal questions left today.'
          : 'Great job! You completed today\'s $dailyGoal-question goal.';

      eveningTitle = 'Keep your ${currentStreak}-day streak alive!';
      eveningBody = remaining > 0
          ? '$remaining questions left to reach your $dailyGoal-question goal before the day ends!'
          : 'Goal reached today! Your $currentStreak-day streak is safe.';
    }

    await _scheduleAtTimeOfDay(
      id: _noonNotificationId,
      hour: 12,
      minute: 0,
      title: noonTitle,
      body: noonBody,
    );

    await _scheduleAtTimeOfDay(
      id: _eveningNotificationId,
      hour: 20,
      minute: 30,
      title: eveningTitle,
      body: eveningBody,
    );
  }

  Future<void> _scheduleAtTimeOfDay({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Nếu giờ hôm nay đã trôi qua thì đặt cho ngày mai
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Không đặt được lịch thông báo ($id): $e');
    }
  }

  /// Hủy toàn bộ thông báo nhắc nhở đã lên lịch.
  Future<void> cancelAllReminders() async {
    await init();
    await _plugin.cancel(_noonNotificationId);
    await _plugin.cancel(_eveningNotificationId);
  }

  /// Hiện thông báo ngay lập tức lên màn hình điện thoại để test / demo.
  Future<void> showTestNotification({
    required int dailyGoal,
    required int todayAnsweredCount,
    required int currentStreak,
    required bool isVietnamese,
  }) async {
    await init();
    final remaining = (dailyGoal - todayAnsweredCount).clamp(0, dailyGoal);

    final title = isVietnamese
        ? '[Test] Nhắc chỉ tiêu & giữ chuỗi ($currentStreak ngày)'
        : '[Test] Daily Goal & Streak (${currentStreak}d)';

    final body = isVietnamese
        ? 'Đã làm $todayAnsweredCount/$dailyGoal câu (còn $remaining câu). Hoàn thành đủ chỉ tiêu trong ngày để không mất chuỗi!'
        : 'Completed $todayAnsweredCount/$dailyGoal questions ($remaining left). Finish your goal today to keep your streak!';

    await _plugin.show(
      _testNotificationId,
      title,
      body,
      _buildNotificationDetails(),
    );
  }
}