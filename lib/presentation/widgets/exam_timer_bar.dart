import 'package:flutter/material.dart';

import '../../domain/exam_countdown.dart';
import '../strings_context.dart';

/// Thanh hiển thị thời gian còn lại và số câu đã trả lời. Khi sắp hết giờ đổi biểu tượng
/// và màu nền, đồng thời có nhãn đọc cho trình đọc màn hình.
class ExamTimerBar extends StatelessWidget {
  const ExamTimerBar({
    super.key,
    required this.remaining,
    required this.warning,
    required this.answered,
    required this.total,
  });

  final Duration remaining;
  final bool warning;
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = context.strings;
    final time = ExamCountdown.format(remaining);
    return Container(
      width: double.infinity,
      color: warning ? scheme.errorContainer : scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Semantics(
            label: warning ? strings.almostOutOfTime(time) : strings.timeLeft(time),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(warning ? Icons.warning_amber : Icons.timer_outlined),
                  const SizedBox(width: 8),
                  Text(
                    strings.timeLeft(time),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(strings.answeredOf(answered, total)),
        ],
      ),
    );
  }
}
