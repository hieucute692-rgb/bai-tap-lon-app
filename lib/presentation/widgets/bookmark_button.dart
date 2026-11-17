import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bookmark_controller.dart';
import '../strings_context.dart';

/// Nút đánh dấu / bỏ đánh dấu một câu hỏi; dùng ở luyện tập, thi thử và màn kết quả.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.questionId});

  final int questionId;

  @override
  Widget build(BuildContext context) {
    final marked = context.watch<BookmarkController>().isBookmarked(questionId);
    final s = context.strings;
    return IconButton(
      tooltip: marked ? s.removeBookmark : s.bookmarkTooltip,
      isSelected: marked,
      icon: const Icon(Icons.bookmark_border),
      selectedIcon: const Icon(Icons.bookmark),
      onPressed: () => context.read<BookmarkController>().toggle(questionId),
    );
  }
}
