import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/asset_question_repository.dart';
import 'domain/question_repository.dart';
import 'presentation/home_screen.dart';
import 'presentation/question_bank_controller.dart';

void main() => runApp(QuizApp(repository: AssetQuestionRepository()));

class QuizApp extends StatelessWidget {
  const QuizApp({super.key, required this.repository});

  final QuestionRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuestionBankController(repository)..load(),
      child: MaterialApp(
        title: 'Ôn tập Flutter',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
