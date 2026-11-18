import 'package:flutter/material.dart';

import '../app_theme.dart';

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
    final Color background;
    final IconData? icon;
    final Color? iconColor;
    switch (state) {
      case OptionState.idle:
        background = Colors.white;
        icon = null;
        iconColor = null;
      case OptionState.selected:
        background = AppColors.selectedTint;
        icon = Icons.radio_button_checked;
        iconColor = AppColors.primary;
      case OptionState.correct:
        background = AppColors.stats.background;
        icon = Icons.check_circle;
        iconColor = AppColors.stats.icon;
      case OptionState.wrong:
        background = AppColors.retry.background;
        icon = Icons.cancel;
        iconColor = AppColors.retry.icon;
    }
    final radius = BorderRadius.circular(16);
    return Card(
      color: background,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        borderRadius: radius,
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
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: iconColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
