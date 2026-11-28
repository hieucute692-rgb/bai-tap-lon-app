import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/study_notification_service.dart';
import '../domain/progress_stats.dart';
import '../domain/question.dart';
import '../domain/question_bank.dart';
import 'bookmark_controller.dart';
import 'bookmarks_screen.dart';
import 'exam_setup_screen.dart';
import 'practice_screen.dart';
import 'practice_setup_screen.dart';
import 'progress_controller.dart';
import 'question_bank_controller.dart';
import 'question_manager_screen.dart';
import 'quick_study_blocks_screen.dart';
import 'search_questions_screen.dart';
import 'settings_controller.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'strings_context.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<QuestionBankController>();
    final s = context.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.surface
          : const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: switch (c.status) {
              LoadStatus.loading =>
              const Center(child: CircularProgressIndicator()),
              LoadStatus.error => _Message(
                icon: Icons.error_outline_rounded,
                text: s.bankLoadError,
                actionLabel: s.retry,
                onAction: c.load,
              ),
              LoadStatus.ready => c.bank == null
                  ? _Message(
                icon: Icons.inbox_outlined,
                text: s.noQuestions,
                actionLabel: s.reload,
                onAction: c.load,
              )
                  : _Menu(bank: c.bank!),
            },
          ),
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.bank});

  final QuestionBank bank;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final settings = context.watch<SettingsController>();
    final bookmarks = context.watch<BookmarkController>();
    final bankController = context.watch<QuestionBankController>();

    final s = settings.strings;
    final isVi = s.language == ContentLanguage.vi;
    final stats = progress.stats;

    final completed = bank.questions.where((q) {
      final stat = stats[q.id];
      return stat != null && stat.attempts > 0;
    }).length;

    final correct = bank.questions.where((q) {
      final stat = stats[q.id];
      return stat != null && stat.attempts > 0 && stat.lastCorrect;
    }).length;

    final wrong = wrongQuestions(bank, stats);
    final remaining =
    (bank.questions.length - completed).clamp(0, bank.questions.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderSection(
            title: bankController.currentSubject?.name ?? s.appTitle,
            subtitle: s.questionsAndBlocks(
              bank.questions.length,
              bank.blocks.length,
            ),
            settingsTooltip: s.settings,
            onSelectSubject: () => _chooseSubject(context, bankController),
            onOpenSettings: () => _push(context, const SettingsScreen()),
            onOpenNotifications: () => _showSnack(
              context,
              isVi ? 'Không có thông báo mới' : 'No new notifications',
            ),
          ),
          const SizedBox(height: 16),
          _SearchBarRow(
            prompt: s.searchHomePrompt,
            onSearchTap: () =>
                _push(context, SearchQuestionsScreen(bank: bank)),
            onFilterTap: () =>
                _push(context, SearchQuestionsScreen(bank: bank)),
          ),
          const SizedBox(height: 18),
          if (bank.isEmpty) ...[
            _EmptyBankCard(
              message: s.noQuestions,
              addLabel: s.addQuestion,
              onAdd: bankController.currentSubject == null
                  ? null
                  : () => _push(
                context,
                QuestionFormScreen(
                  subject: bankController.currentSubject!,
                  initialQuestion: null,
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          _ProgressCard(
            completed: completed,
            total: bank.questions.length,
            correct: correct,
            wrong: wrong.length,
            remaining: remaining,
            label: isVi ? 'Tiến độ học' : 'Learning progress',
            dailyGoal: progress.dailyGoal,
            todayAnsweredCount: progress.todayAnsweredCount,
            currentStreak: progress.currentStreak,
            goalComplete: progress.dailyGoalComplete,
            onChooseGoal: () => _chooseDailyGoal(context, progress),
          ),
          const SizedBox(height: 22),
          Text(
            isVi ? 'CHỨC NĂNG CHÍNH' : 'MAIN FEATURES',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF64748B),
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _FeatureGridContainer(
            items: [
              _FeatureItemData(
                icon: Icons.menu_book_rounded,
                title: s.practice,
                gradientColors: const [Color(0xFFE3EEFF), Color(0xFFD2E4FF)],
                iconGradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                onTap: () {
                  if (bank.isEmpty) {
                    _showSnack(context, s.noQuestions);
                    return;
                  }
                  _push(context, PracticeSetupScreen(bank: bank));
                },
              ),
              _FeatureItemData(
                icon: Icons.timer_rounded,
                title: s.exam,
                gradientColors: const [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
                iconGradient: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                onTap: () {
                  if (bank.isEmpty) {
                    _showSnack(context, s.noQuestions);
                    return;
                  }
                  _push(context, ExamSetupScreen(bank: bank));
                },
              ),
              _FeatureItemData(
                icon: Icons.bar_chart_rounded,
                title: s.stats,
                gradientColors: const [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                iconGradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                onTap: () => _push(context, StatsScreen(bank: bank)),
              ),
              _FeatureItemData(
                icon: Icons.bolt_rounded,
                title: s.quickStudy,
                gradientColors: const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                iconGradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                onTap: () =>
                    _push(context, QuickStudyBlocksScreen(bank: bank)),
              ),
              _FeatureItemData(
                icon: Icons.replay_rounded,
                title: isVi ? 'Câu sai' : 'Wrong',
                gradientColors: const [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
                iconGradient: const [Color(0xFFFB7185), Color(0xFFE11D48)],
                badge: wrong.isEmpty ? null : wrong.length,
                onTap: () {
                  if (wrong.isEmpty) {
                    _showSnack(context, s.noWrongYet);
                    return;
                  }
                  _push(
                    context,
                    PracticeScreen(
                      titleOf: (str) => str.retryWrong,
                      questions: wrong,
                    ),
                  );
                },
              ),
              _FeatureItemData(
                icon: Icons.bookmark_rounded,
                title: isVi ? 'Đánh dấu' : 'Saved',
                gradientColors: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                iconGradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                badge: bookmarks.count == 0 ? null : bookmarks.count,
                onTap: () => _push(context, BookmarksScreen(bank: bank)),
              ),
              _FeatureItemData(
                icon: Icons.folder_rounded,
                title: s.manageQuestions,
                gradientColors: const [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
                iconGradient: const [Color(0xFF6366F1), Color(0xFF4338CA)],
                onTap: () =>
                    _push(context, const QuestionManagerSubjectsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _chooseDailyGoal(
      BuildContext context,
      ProgressController progress,
      ) async {
    final settings = context.read<SettingsController>();
    final s = settings.strings;
    final isVi = settings.language == ContentLanguage.vi;

    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  s.chooseDailyGoal,
                  style: Theme.of(sheetCtx).textTheme.titleMedium,
                ),
              ),
              for (final goal in [10, 15, 30, 45])
                ListTile(
                  title: Text(s.dailyGoalOption(goal)),
                  trailing: progress.dailyGoal == goal
                      ? Icon(
                    Icons.check_rounded,
                    color: Theme.of(sheetCtx).colorScheme.primary,
                  )
                      : null,
                  onTap: () => Navigator.of(sheetCtx).pop(goal),
                ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text(isVi ? 'Nhập số câu tùy chỉnh...' : 'Custom goal...'),
                onTap: () => Navigator.of(sheetCtx).pop(-1),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;

    int? finalGoal = selected;
    if (selected == -1) {
      finalGoal = await showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (_) => _CustomGoalDialog(
          currentGoal: progress.dailyGoal,
          isVi: isVi,
          saveLabel: s.save,
          cancelLabel: s.goBack,
        ),
      );
    }

    if (!context.mounted || finalGoal == null || finalGoal <= 0) return;

    await progress.setDailyGoal(finalGoal);
    if (settings.notificationsEnabled) {
      await StudyNotificationService.instance.scheduleDailyReminders(
        dailyGoal: finalGoal,
        todayAnsweredCount: progress.todayAnsweredCount,
        currentStreak: progress.currentStreak,
        isVietnamese: isVi,
      );
    }
  }

  Future<void> _chooseSubject(
      BuildContext context,
      QuestionBankController controller,
      ) async {
    final s = context.stringsNow;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                s.selectSubject,
                style: Theme.of(sheetCtx).textTheme.titleMedium,
              ),
            ),
            for (final sub in controller.subjects)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(sub.name),
                subtitle: Text(sub.fileName),
                trailing: controller.currentSubject?.id == sub.id
                    ? Icon(
                  Icons.check_rounded,
                  color: Theme.of(sheetCtx).colorScheme.primary,
                )
                    : null,
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  await controller.selectSubject(sub);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(s.newSubject),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showCreateSubjectDialog(context, controller);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateSubjectDialog(
      BuildContext context,
      QuestionBankController controller,
      ) async {
    final s = context.stringsNow;
    final nameCtrl = TextEditingController();
    final createdName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.newSubject),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(hintText: s.subjectName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.goBack),
          ),
          FilledButton(
            onPressed: () {
              final text = nameCtrl.text.trim();
              if (text.isNotEmpty) Navigator.pop(ctx, text);
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    if (createdName != null && createdName.isNotEmpty) {
      await controller.createSubject(createdName);
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.title,
    required this.subtitle,
    required this.settingsTooltip,
    required this.onSelectSubject,
    required this.onOpenSettings,
    required this.onOpenNotifications,
  });

  final String title;
  final String subtitle;
  final String settingsTooltip;
  final VoidCallback onSelectSubject;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onSelectSubject,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        _HeaderActionButton(
          icon: Icons.settings_outlined,
          tooltip: settingsTooltip,
          onTap: onOpenSettings,
        ),
        const SizedBox(width: 8),
        _HeaderActionButton(
          icon: Icons.notifications_rounded,
          tooltip: 'Notifications',
          onTap: onOpenNotifications,
        ),
      ],
    );
  }
}

class _CustomGoalDialog extends StatefulWidget {
  const _CustomGoalDialog({
    required this.currentGoal,
    required this.isVi,
    required this.saveLabel,
    required this.cancelLabel,
  });

  final int currentGoal;
  final bool isVi;
  final String saveLabel;
  final String cancelLabel;

  @override
  State<_CustomGoalDialog> createState() => _CustomGoalDialogState();
}

class _CustomGoalDialogState extends State<_CustomGoalDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentGoal}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed != null && parsed > 0) {
      Navigator.of(context).pop(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isVi
            ? 'Số câu cần hoàn thành mỗi ngày'
            : 'Daily question goal',
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: widget.isVi ? 'Ví dụ: 20' : 'e.g. 20',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : const Color(0xFFE9ECF5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBarRow extends StatelessWidget {
  const _SearchBarRow({
    required this.prompt,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final String prompt;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : const Color(0xFFE9ECF5);

    return Row(
      children: [
        Expanded(
          child: Material(
            color: boxColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onSearchTap,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF2563EB),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: boxColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onFilterTap,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.filter_alt_outlined,
                color: Color(0xFF2563EB),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBankCard extends StatelessWidget {
  const _EmptyBankCard({
    required this.message,
    required this.addLabel,
    required this.onAdd,
  });

  final String message;
  final String addLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            if (onAdd != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(addLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.remaining,
    required this.label,
    required this.dailyGoal,
    required this.todayAnsweredCount,
    required this.currentStreak,
    required this.goalComplete,
    required this.onChooseGoal,
  });

  final int completed;
  final int total;
  final int correct;
  final int wrong;
  final int remaining;
  final String label;
  final int dailyGoal;
  final int todayAnsweredCount;
  final int currentStreak;
  final bool goalComplete;
  final VoidCallback onChooseGoal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.strings.language == ContentLanguage.vi;
    final percent = total == 0 ? 0 : (completed * 100 / total).round();
    final progressValue =
    total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0).toDouble();
    final safeGoal = dailyGoal <= 0 ? 1 : dailyGoal;
    final goalRatio = (todayAnsweredCount / safeGoal).clamp(0.0, 1.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? LinearGradient(
          colors: [
            scheme.surfaceContainerHigh,
            scheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [
            Color(0xFFEEF4FF),
            Color(0xFFFDFDFF),
            Color(0xFFF3EEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? scheme.outlineVariant.withValues(alpha: 0.3)
              : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                isVi
                    ? '$completed / $total câu'
                    : '$completed / $total questions',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GradientProgressBar(
                  value: progressValue,
                  height: 8,
                  trackColor: const Color(0xFFDCE4F7),
                  gradientColors: const [
                    Color(0xFF3B82F6),
                    Color(0xFF8B5CF6),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProgressStatTile(
                count: correct,
                label: isVi ? 'đúng' : 'correct',
                textColor: const Color(0xFF16A34A),
                bgColor: isDark ? scheme.surface : Colors.white,
              ),
              _ProgressStatTile(
                count: wrong,
                label: isVi ? 'sai' : 'wrong',
                textColor: const Color(0xFFDC2626),
                bgColor: isDark ? scheme.surface : Colors.white,
              ),
              _ProgressStatTile(
                count: remaining,
                label: isVi ? 'còn lại' : 'left',
                textColor: const Color(0xFF334155),
                bgColor: isDark
                    ? scheme.surfaceContainerHighest
                    : const Color(0xFFE4E7F1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.strings.dailyGoal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (goalComplete) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF16A34A),
                            size: 16,
                          ),
                        ],
                        const SizedBox(width: 8),
                        Material(
                          color: isDark ? scheme.surface : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          elevation: 1,
                          shadowColor: Colors.black12,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: onChooseGoal,
                            child: const SizedBox(
                              width: 34,
                              height: 30,
                              child: Icon(
                                Icons.tune_rounded,
                                size: 17,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.strings.dailyGoalProgress(
                        todayAnsweredCount,
                        dailyGoal,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _GradientProgressBar(
                      value: goalRatio,
                      height: 6,
                      trackColor: const Color(0xFFDCE4F7),
                      gradientColors: goalComplete
                          ? const [Color(0xFF22C55E), Color(0xFF16A34A)]
                          : const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9A44), Color(0xFFFF3D77)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D77).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.strings.studyStreak(currentStreak),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  const _GradientProgressBar({
    required this.value,
    required this.height,
    required this.trackColor,
    required this.gradientColors,
  });

  final double value;
  final double height;
  final Color trackColor;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * value.clamp(0.0, 1.0);
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressStatTile extends StatelessWidget {
  const _ProgressStatTile({
    required this.count,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });

  final int count;
  final String label;
  final Color textColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItemData {
  const _FeatureItemData({
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.iconGradient,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final List<Color> iconGradient;
  final VoidCallback onTap;
  final int? badge;
}

class _FeatureGridContainer extends StatelessWidget {
  const _FeatureGridContainer({required this.items});

  final List<_FeatureItemData> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : const Color(0xFFF0F2FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.white,
          width: 1.5,
        ),
      ),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 8,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) => _FeatureGridTile(item: items[index]),
      ),
    );
  }
}

class _FeatureGridTile extends StatelessWidget {
  const _FeatureGridTile({required this.item});

  final _FeatureItemData item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: item.iconGradient.last.withValues(alpha: 0.16),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: item.iconGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Icon(
                        item.icon,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: _Badge(count: item.badge!),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFB91C1C),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}