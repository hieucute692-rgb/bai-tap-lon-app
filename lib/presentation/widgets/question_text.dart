import 'package:flutter/material.dart';

import '../../domain/question_text.dart';

/// Hiển thị nội dung câu hỏi: văn bản thường và đoạn mã (font đơn cách, cuộn ngang).
class QuestionText extends StatelessWidget {
  const QuestionText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final segments = parseQuestionText(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in segments)
          switch (s) {
            TextSegment(:final content) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(content),
              ),
            CodeSegment(:final content) => _CodeBlock(code: content),
          },
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ),
    );
  }
}
