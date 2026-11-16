/// Một đoạn của nội dung câu hỏi: văn bản thường hoặc đoạn mã.
sealed class QuestionSegment {
  const QuestionSegment(this.content);
  final String content;
}

class TextSegment extends QuestionSegment {
  const TextSegment(super.content);
}

class CodeSegment extends QuestionSegment {
  const CodeSegment(super.content, {this.language = 'dart'});
  final String language;
}

final _fence = RegExp(r'```(\w*)\n(.*?)\n```', dotAll: true);

/// Tách nội dung câu hỏi thành các đoạn văn bản và đoạn mã (khối ```dart ... ```).
List<QuestionSegment> parseQuestionText(String text) {
  final segments = <QuestionSegment>[];
  var cursor = 0;
  for (final m in _fence.allMatches(text)) {
    final before = text.substring(cursor, m.start).trim();
    if (before.isNotEmpty) segments.add(TextSegment(before));
    final lang = m.group(1)!;
    segments.add(CodeSegment(m.group(2)!, language: lang.isEmpty ? 'dart' : lang));
    cursor = m.end;
  }
  final tail = text.substring(cursor).trim();
  if (tail.isNotEmpty) segments.add(TextSegment(tail));
  return segments;
}
