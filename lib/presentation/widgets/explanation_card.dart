import 'package:flutter/material.dart';

import '../strings_context.dart';

class ExplanationCard extends StatelessWidget {
  const ExplanationCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.strings.explanation, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(text),
          ],
        ),
      ),
    );
  }
}
