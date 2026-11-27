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
        padding: const EdgeInsets.all(16),
        children: [
          _SettingGroupCard(
            title: s.displayLanguage,
            child: SegmentedButton<ContentLanguage>(
              segments: const [
                ButtonSegment(value: ContentLanguage.vi, label: Text('Tiếng Việt')),
                ButtonSegment(value: ContentLanguage.en, label: Text('English')),
              ],
              selected: {settings.language},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  settings.setLanguage(selection.first),
              style: _segmentStyle(scheme, horizontalPad: 12),
            ),
          ),
          const SizedBox(height: 10),
          _SettingGroupCard(
            title: s.appearance,
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(s.themeLight)),
                ButtonSegment(value: ThemeMode.system, label: Text(s.themeSystem)),
                ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark)),
              ],
              selected: {settings.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  settings.setThemeMode(selection.first),
              style: _segmentStyle(scheme, horizontalPad: 8),
            ),
          ),
        ],
      ),
    );
  }
}

ButtonStyle _segmentStyle(ColorScheme scheme, {required double horizontalPad}) {
  return SegmentedButton.styleFrom(
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurfaceVariant,
    selectedBackgroundColor: scheme.primary,
    selectedForegroundColor: scheme.onPrimary,
    side: BorderSide(color: scheme.outline),
    shape: const StadiumBorder(),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8),
    visualDensity: VisualDensity.compact,
  );
}

class _SettingGroupCard extends StatelessWidget {
  const _SettingGroupCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}