import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/question.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final s = settings.strings;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(s.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(   // Đổi ngôn ngữ toàn app qua SettingsController.
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.displayLanguage,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ContentLanguage>(
                    segments: const <ButtonSegment<ContentLanguage>>[
                      ButtonSegment(
                        value: ContentLanguage.vi,
                        label: Text('Tiếng Việt'),
                      ),
                      ButtonSegment(
                        value: ContentLanguage.en,
                        label: Text('English'),
                      ),
                    ],
                    selected: {settings.language},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        settings.setLanguage(selection.first),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: scheme.onSurfaceVariant,
                      selectedBackgroundColor: scheme.primary,
                      selectedForegroundColor: scheme.onPrimary,
                      side: BorderSide(color: scheme.outline),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(   // Đổi ngôn ngữ toàn app qua SettingsController.
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.appearance,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(s.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(s.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(s.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        settings.setThemeMode(selection.first),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: scheme.onSurfaceVariant,
                      selectedBackgroundColor: scheme.primary,
                      selectedForegroundColor: scheme.onPrimary,
                      side: BorderSide(color: scheme.outline),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}