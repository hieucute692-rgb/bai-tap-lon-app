import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/json_subject_store.dart';
import 'data/shared_prefs_bookmark_repository.dart';
import 'data/shared_prefs_daily_study_repository.dart';
import 'data/shared_prefs_progress_repository.dart';
import 'data/shared_prefs_settings_repository.dart';
import 'data/study_notification_service.dart';
import 'domain/bookmark_repository.dart';
import 'domain/daily_study_repository.dart';
import 'domain/progress_repository.dart';
import 'domain/settings_repository.dart';
import 'presentation/app_theme.dart';
import 'presentation/bookmark_controller.dart';
import 'presentation/home_screen.dart';
import 'presentation/progress_controller.dart';
import 'presentation/question_bank_controller.dart';
import 'presentation/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StudyNotificationService.instance.init();

  runApp(
    QuizApp(
      subjectStore: JsonSubjectStore(),
      progressRepository: SharedPrefsProgressRepository(),
      dailyStudyRepository: SharedPrefsDailyStudyRepository(),
      settingsRepository: SharedPrefsSettingsRepository(),
      bookmarkRepository: SharedPrefsBookmarkRepository(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({
    super.key,
    required this.subjectStore,
    required this.progressRepository,
    this.dailyStudyRepository,
    required this.settingsRepository,
    required this.bookmarkRepository,
  });

  final JsonSubjectStore subjectStore;
  final ProgressRepository progressRepository;
  final DailyStudyRepository? dailyStudyRepository;
  final SettingsRepository settingsRepository;
  final BookmarkRepository bookmarkRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressController>(
          create: (_) => ProgressController(
            progressRepository,
            dailyStudyRepository: dailyStudyRepository,
          )..load(),
        ),
        ChangeNotifierProvider<BookmarkController>(
          create: (_) => BookmarkController(bookmarkRepository)..load(),
        ),
        ChangeNotifierProxyProvider<ProgressController, QuestionBankController>(
          create: (context) => QuestionBankController(
            subjectStore,
            onSubjectChanged: (subjectId) async {
              await context.read<ProgressController>().setSubject(subjectId);
              await context.read<BookmarkController>().setSubject(subjectId);
            },
          )..load(),
          update: (context, progress, previous) =>
          previous ??
              QuestionBankController(
                subjectStore,
                onSubjectChanged: (subjectId) async {
                  await progress.setSubject(subjectId);
                  await context.read<BookmarkController>().setSubject(subjectId);
                },
              )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsController(settingsRepository)..load(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Ôn tập Flutter',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}