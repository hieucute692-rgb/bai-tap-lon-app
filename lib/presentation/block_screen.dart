import 'package:flutter/material.dart';

import '../domain/question_bank.dart';
import 'widgets/question_text.dart';

/// Xem nhanh các câu của một khối (màn hình tạm để kiểm tra dữ liệu và hiển thị mã).
class BlockScreen extends StatelessWidget {
  const BlockScreen({super.key, required this.bank, required this.block});

  final QuestionBank bank;
  final QuestionBlock block;

  @override
  Widget build(BuildContext context) {
    final questions = bank.inBlock(block.id);
    return Scaffold(
      appBar: AppBar(title: Text('Khối ${block.id}. ${block.nameVi}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: questions.length,
        itemBuilder: (context, i) {
          final q = questions[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Câu ${q.id}', style: Theme.of(context).textTheme.titleSmall),
                  QuestionText(q.questionVi),
                  const SizedBox(height: 8),
                  for (var k = 0; k < q.optionsVi.length; k++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('${'ABCD'[k]}. ${q.optionsVi[k]}'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
