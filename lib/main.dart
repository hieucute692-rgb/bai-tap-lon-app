import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/asset_question_repository.dart';
import 'data/shared_prefs_progress_repository.dart';
import 'domain/progress_repository.dart';
import 'domain/question_repository.dart';
import 'presentation/home_screen.dart';
import 'presentation/progress_controller.dart';
import 'presentation/question_bank_controller.dart';

void main() => runApp(
      QuizApp(
        repository: AssetQuestionRepository(),
        progressRepository: SharedPrefsProgressRepository(),
      ),
    );

class QuizApp extends StatelessWidget {
  const QuizApp({
    super.key,
    required this.repository,
    required this.progressRepository,
  });

  final QuestionRepository repository;
  final ProgressRepository progressRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionBankController(repository)..load()),
        ChangeNotifierProvider(create: (_) => ProgressController(progressRepository)..load()),
      ],
      child: MaterialApp(
        title: 'Ôn tập Flutter',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
