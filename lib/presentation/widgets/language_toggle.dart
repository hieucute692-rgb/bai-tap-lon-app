import 'package:flutter/material.dart';

import '../../domain/question.dart';

/// Nút đổi nhanh ngôn ngữ hiển thị nội dung câu hỏi (VI / EN).
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, required this.language, required this.onChanged});

  final ContentLanguage language;
  final ValueChanged<ContentLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SegmentedButton<ContentLanguage>(
        segments: const <ButtonSegment<ContentLanguage>>[
          ButtonSegment(value: ContentLanguage.vi, label: Text('VI')),
          ButtonSegment(value: ContentLanguage.en, label: Text('EN')),
        ],
        selected: {language},
        showSelectedIcon: false,
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
