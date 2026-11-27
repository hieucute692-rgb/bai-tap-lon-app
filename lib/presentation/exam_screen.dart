import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/exam.dart';
import '../domain/exam_countdown.dart';
import '../domain/question.dart';
import 'exam_result_screen.dart';
import 'progress_controller.dart';
import 'settings_controller.dart';
import 'strings_context.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/exam_timer_bar.dart';
import 'widgets/language_toggle.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Làm bài thi thử có đồng hồ đếm ngược: chọn/đổi đáp án tự do, không hiện đúng sai cho tới
/// khi nộp bài. Hết giờ thì tự nộp. Không thoát ra ngoài được cho tới khi nộp bài: nút quay
/// lại và cử chỉ vuốt lùi chỉ mở hộp thoại nộp bài.
class ExamScreen extends StatefulWidget {
  const ExamScreen({
    super.key,
    required this.questions,
    required this.duration,
    this.clock,
  });

  final List<Question> questions;
  final Duration duration;

  /// Nguồn thời gian, để test điều khiển được; mặc định là giờ hệ thống.
  final DateTime Function()? clock;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: borderColor, width: 1.2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  late final ExamSession _session = ExamSession(widget.questions);
  late final DateTime Function() _now;
  late final ExamCountdown _countdown;
  Timer? _ticker;
  int _index = 0;
  bool _submitted = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _now = widget.clock ?? DateTime.now;
    _countdown = ExamCountdown(duration: widget.duration, startedAt: _now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quay lại từ nền: kiểm tra ngay thay vì chờ nhịp Timer tiếp theo.
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _tick() {
    if (_submitted || !mounted) return;
    if (_countdown.isExpired(_now())) {
      _finish(timedOut: true);
    } else {
      setState(() {});
    }
  }

  /// Chấm, ghi tiến độ và chuyển sang màn kết quả. Chỉ chạy một lần dù nộp tay hay hết giờ.
  void _finish({required bool timedOut}) {
    if (_submitted) return;
    _submitted = true;
    _ticker?.cancel();
    if (_dialogOpen) {
      _dialogOpen = false;
      Navigator.of(context).pop(); // đóng hộp thoại xác nhận đang mở
    }
    final progress = context.read<ProgressController>();
    progress.recordAnswers(
      _session.outcomes(),
      activityCount: _session.answeredCount,
    );
    progress.addExamResult(_session.toResult(_now()));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExamResultScreen(session: _session, timedOut: timedOut),
      ),
    );
  }

  /// [fromBack]: người dùng bấm quay lại; giải thích vì sao chưa thoát được rồi hỏi nộp bài.
  Future<void> _submit({bool fromBack = false}) async {
    if (_submitted) return;
    final s = context.stringsNow;
    final unanswered = _session.unansweredCount;
    final message =
    unanswered == 0 ? s.allAnswered : s.unansweredWarning(unanswered);
    _dialogOpen = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.submitQuestion),
        content: Text(
          fromBack ? '${s.cannotLeaveExam}\n\n$message' : message,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.keepGoing),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.submit),
          ),
        ],
      ),
    );
    _dialogOpen = false;
    if (confirmed != true || !mounted) return;
    _finish(timedOut: false);
  }

  // Mở bottom sheet dạng lưới hiển thị trạng thái đã làm / chưa làm và cho phép nhảy tới câu bất kỳ.
  Future<void> _openQuestionNavigator() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final total = _session.questions.length;

    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF6F7FB),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_session.answeredCount}/$total',
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _LegendDot(
                      color: const Color(0xFFE3EEFF),
                      borderColor: const Color(0xFF3B82F6),
                      label: 'Đã làm',
                    ),
                    const SizedBox(width: 12),
                    _LegendDot(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderColor: const Color(0xFFCBD5E1),
                      label: 'Chưa làm',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: total,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (_, i) {
                      final q = _session.questions[i];
                      final isAnswered = _session.answerOf(q) != null;
                      final isCurrent = i == _index;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(sheetContext).pop(i),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isCurrent
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF8B5CF6),
                                ],
                              )
                                  : null,
                              color: isCurrent
                                  ? null
                                  : (isAnswered
                                  ? const Color(0xFFE3EEFF)
                                  : (isDark
                                  ? colorScheme.surfaceContainerHigh
                                  : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.white
                                    : (isAnswered
                                    ? const Color(0xFF93C5FD)
                                    : const Color(0xFFE2E8F0)),
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.white
                                    : (isAnswered
                                    ? const Color(0xFF1E40AF)
                                    : (isDark
                                    ? colorScheme.onSurface
                                    : const Color(0xFF334155))),
                                fontWeight: isCurrent || isAnswered
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nhảy thẳng tới câu được chọn sau khi đóng bottom sheet.
    if (selectedIndex != null && mounted) {
      setState(() => _index = selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final lang = settings.language;
    final s = settings.strings;
    final total = _session.questions.length;
    final q = _session.questions[_index];
    final options = q.optionsFor(lang);
    final selected = _session.answerOf(q);
    final now = _now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final progressValue =
    total == 0 ? 0.0 : ((_index + 1) / total).clamp(0.0, 1.0);

    return PopScope(
      canPop: false, // chỉ thoát được bằng cách nộp bài (hoặc khi hết giờ)
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _submit(fromBack: true);
      },
      child: Scaffold(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            s.exam,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            LanguageToggle(language: lang, onChanged: settings.setLanguage),
            const SizedBox(width: 6),
            TextButton(
              onPressed: _submit,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: Text(s.submit),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Material(
                color: isDark ? scheme.surfaceContainerHigh : Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _openQuestionNavigator,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                        isDark ? Colors.white10 : const Color(0xFFE8ECF7),
                      ),
                    ),
                    child: ExamTimerBar(
                      remaining: _countdown.remaining(now),
                      warning: _countdown.isWarning(now),
                      answered: _session.answeredCount,
                      total: total,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Semantics(
                label: s.questionPosition,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    height: 7,
                    color: const Color(0xFFDCE4F7),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progressValue,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
                    key: ValueKey(_index),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? scheme.surfaceContainer : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : const Color(0xFFE8ECF7),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _openQuestionNavigator,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE3EEFF),
                                          Color(0xFFEDE9FE),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          s.examQuestionHeader(
                                            _index + 1,
                                            total,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                            color: const Color(0xFF1E40AF),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: Color(0xFF1E40AF),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                BookmarkButton(questionId: q.id),
                              ],
                            ),
                            const SizedBox(height: 12),
                            QuestionText(q.questionFor(lang)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < options.length; i++)
                        OptionTile(
                          letter: 'ABCD'[i],
                          text: options[i],
                          state: selected == i
                              ? OptionState.selected
                              : OptionState.idle,
                          onTap: () => setState(() => _session.answer(q, i)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _index == 0
                                  ? null
                                  : () => setState(() => _index--),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isDark
                                    ? scheme.surfaceContainerHigh
                                    : Colors.white,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : const Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                s.previous,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: _index == total - 1
                                    ? null
                                    : const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),
                                color: _index == total - 1
                                    ? (isDark
                                    ? scheme.surfaceContainerHighest
                                    : const Color(0xFFE2E8F0))
                                    : null,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: _index == total - 1
                                    ? null
                                    : [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _index == total - 1
                                    ? null
                                    : () => setState(() => _index++),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  s.next,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _index == total - 1
                                        ? const Color(0xFF94A3B8)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}