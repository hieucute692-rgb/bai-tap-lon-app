import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/asset_question_repository.dart';
import 'data/shared_prefs_bookmark_repository.dart';
import 'data/shared_prefs_progress_repository.dart';
import 'data/shared_prefs_settings_repository.dart';
import 'domain/bookmark_repository.dart';
import 'domain/progress_repository.dart';
import 'domain/question_repository.dart';
import 'domain/settings_repository.dart';
import 'presentation/app_theme.dart';
import 'presentation/bookmark_controller.dart';
import 'presentation/home_screen.dart';
import 'presentation/progress_controller.dart';
import 'presentation/question_bank_controller.dart';
import 'presentation/settings_controller.dart';

void main() => runApp(
      QuizApp(
        repository: AssetQuestionRepository(),
        progressRepository: SharedPrefsProgressRepository(),
        settingsRepository: SharedPrefsSettingsRepository(),
        bookmarkRepository: SharedPrefsBookmarkRepository(),
      ),
    );

class QuizApp extends StatelessWidget {
  const QuizApp({
    super.key,
    required this.repository,
    required this.progressRepository,
    required this.settingsRepository,
    required this.bookmarkRepository,
  });

  final QuestionRepository repository;
  final ProgressRepository progressRepository;
  final SettingsRepository settingsRepository;
  final BookmarkRepository bookmarkRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionBankController(repository)..load()),
        ChangeNotifierProvider(create: (_) => ProgressController(progressRepository)..load()),
        ChangeNotifierProvider(create: (_) => SettingsController(settingsRepository)..load()),
        ChangeNotifierProvider(create: (_) => BookmarkController(bookmarkRepository)..load()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Ôn tập Flutter',
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
