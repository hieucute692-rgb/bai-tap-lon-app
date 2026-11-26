import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/daily_study.dart';
import '../domain/daily_study_repository.dart';

class SharedPrefsDailyStudyRepository implements DailyStudyRepository {
  static const _key = 'daily_study_v1';

  @override
  Future<DailyStudyData?> loadDailyStudy() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return DailyStudyData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Could not read daily study data: $error');
      return null;
    }
  }

  @override
  Future<void> saveDailyStudy(DailyStudyData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }
}
