import 'package:flutter/material.dart';

enum OptionState { idle, selected, correct, wrong }

/// Một lựa chọn A–D. Trạng thái đúng/sai có cả biểu tượng, không chỉ dựa vào màu.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  final String letter;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color background;
    final IconData? icon;
    switch (state) {
      case OptionState.idle:
        background = scheme.surfaceContainerLow;
        icon = null;
      case OptionState.selected:
        background = scheme.secondaryContainer;
        icon = Icons.radio_button_checked;
      case OptionState.correct:
        background = scheme.primaryContainer;
        icon = Icons.check_circle;
      case OptionState.wrong:
        background = scheme.errorContainer;
        icon = Icons.cancel;
    }
    return Card(
      color: background,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(radius: 14, child: Text(letter)),
                const SizedBox(width: 12),
                Expanded(child: Text(text)),
                if (icon != null) ...[const SizedBox(width: 8), Icon(icon)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
