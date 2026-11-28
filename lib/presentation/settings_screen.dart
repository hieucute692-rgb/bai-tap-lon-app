import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/question.dart';
import 'settings_controller.dart';
import 'progress_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final s = settings.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.settings,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              _SettingGroupCard(
                icon: Icons.translate_rounded,
                iconBg: const [Color(0xFFE3EEFF), Color(0xFFD2E4FF)],
                iconFg: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                title: s.displayLanguage,
                child: Row(
                  children: [
                    Expanded(
                      child: _GradientOptionButton(
                        label: 'Tiếng Việt',
                        selected: settings.language == ContentLanguage.vi,
                        onTap: () => settings.setLanguage(ContentLanguage.vi),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GradientOptionButton(
                        label: 'English',
                        selected: settings.language == ContentLanguage.en,
                        onTap: () => settings.setLanguage(ContentLanguage.en),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingGroupCard(
                icon: Icons.palette_rounded,
                iconBg: const [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                iconFg: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                title: s.appearance,
                child: Row(
                  children: [
                    Expanded(
                      child: _GradientOptionButton(
                        label: s.themeLight,
                        selected: settings.themeMode == ThemeMode.light,
                        onTap: () => settings.setThemeMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GradientOptionButton(
                        label: s.themeSystem,
                        selected: settings.themeMode == ThemeMode.system,
                        onTap: () => settings.setThemeMode(ThemeMode.system),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GradientOptionButton(
                        label: s.themeDark,
                        selected: settings.themeMode == ThemeMode.dark,
                        onTap: () => settings.setThemeMode(ThemeMode.dark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingGroupCard(
                icon: Icons.notifications_active_rounded,
                iconBg: const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                iconFg: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                title: settings.language == ContentLanguage.vi
                    ? 'Thông báo nhắc chỉ tiêu & chuỗi'
                    : 'Goal & Streak Notifications',
                child: Builder(
                  builder: (context) {
                    final progress = context.watch<ProgressController>();
                    final isVi = settings.language == ContentLanguage.vi;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isVi
                                        ? 'Nhắc 2 lần/ngày (12:00 & 20:30)'
                                        : 'Twice daily (12:00 & 20:30)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isVi
                                        ? 'Nhắc hoàn thành chỉ tiêu trong ngày để không mất chuỗi'
                                        : 'Reminds you to hit your daily goal and keep your streak',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.notificationsEnabled,
                              onChanged: (value) async {
                                final ok = await settings.setNotificationsEnabled(
                                  enabled: value,
                                  dailyGoal: progress.dailyGoal,
                                  todayAnsweredCount: progress.todayAnsweredCount,
                                  currentStreak: progress.currentStreak,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        !ok
                                            ? (isVi
                                            ? 'Chưa được cấp quyền thông báo trên thiết bị'
                                            : 'Notification permission was not granted')
                                            : (value
                                            ? (isVi
                                            ? 'Đã bật thông báo lúc 12:00 và 20:30'
                                            : 'Enabled reminders at 12:00 & 20:30')
                                            : (isVi
                                            ? 'Đã tắt thông báo nhắc nhở'
                                            : 'Disabled reminders')),
                                      ),
                                    ),
                                  );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await settings.sendTestNotification(
                              dailyGoal: progress.dailyGoal,
                              todayAnsweredCount: progress.todayAnsweredCount,
                              currentStreak: progress.currentStreak,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? (isVi
                                        ? 'Đã gửi thông báo test lên màn hình'
                                        : 'Test notification sent')
                                        : (isVi
                                        ? 'Hãy cấp quyền thông báo để test'
                                        : 'Grant notification permission to test'),
                                  ),
                                ),
                              );
                          },
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            isVi ? 'Test thông báo ngay' : 'Test notification now',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingGroupCard extends StatelessWidget {
  const _SettingGroupCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final List<Color> iconBg;
  final List<Color> iconFg;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconBg,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: iconFg,
                  ).createShader(bounds),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GradientOptionButton extends StatelessWidget {
  const _GradientOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: selected
                ? null
                : (isDark
                ? scheme.surfaceContainerHigh
                : const Color(0xFFF6F7FB)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? Colors.white
                  : (isDark
                  ? scheme.onSurface
                  : const Color(0xFF334155)),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}