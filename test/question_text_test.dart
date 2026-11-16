import 'package:flutter_quiz_300/domain/question_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('văn bản thường là một đoạn', () {
    final s = parseQuestionText('Chỉ có chữ.');
    expect(s, hasLength(1));
    expect(s.single, isA<TextSegment>());
  });

  test('tách văn bản và đoạn mã', () {
    final s = parseQuestionText('Hỏi gì?\n\n```dart\nvar a = 1;\n```');
    expect(s, hasLength(2));
    expect(s[0].content, 'Hỏi gì?');
    expect(s[1], isA<CodeSegment>());
    expect(s[1].content, 'var a = 1;');
  });

  test('nhiều đoạn mã liên tiếp', () {
    final s = parseQuestionText('Ba đoạn:\n\n```dart\na();\n```\n\n```dart\nb();\n```');
    expect(s.whereType<CodeSegment>(), hasLength(2));
  });
}
