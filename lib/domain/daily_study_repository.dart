import 'daily_study.dart';

abstract class DailyStudyRepository {
  Future<DailyStudyData?> loadDailyStudy();
  Future<void> saveDailyStudy(DailyStudyData data);
}
