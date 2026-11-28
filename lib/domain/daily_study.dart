/// Small local snapshot used for the daily goal and study streak.
class DailyStudyData {
  const DailyStudyData({
    this.dailyGoal = 15,
    this.todayAnsweredCount = 0,
    required this.todayDate,
    this.currentStreak = 0,
    this.lastStudyDate,
  });

  final int dailyGoal;
  final int todayAnsweredCount;
  final String todayDate;
  final int currentStreak;
  final String? lastStudyDate;

  Map<String, Object?> toJson() => {
        'dailyGoal': dailyGoal,
        'todayAnsweredCount': todayAnsweredCount,
        'todayDate': todayDate,
        'currentStreak': currentStreak,
        'lastStudyDate': lastStudyDate,
      };

  factory DailyStudyData.fromJson(Map<String, dynamic> json) {
    final goal = json['dailyGoal'];
    final count = json['todayAnsweredCount'];
    final streak = json['currentStreak'];
    final today = json['todayDate'];
    final last = json['lastStudyDate'];
    return DailyStudyData(
      dailyGoal: goal is int && goal > 0 ? goal : 15,
      todayAnsweredCount: count is int && count >= 0 ? count : 0,
      todayDate: today is String ? today : '',
      currentStreak: streak is int && streak >= 0 ? streak : 0,
      lastStudyDate: last is String ? last : null,
    );
  }
}
