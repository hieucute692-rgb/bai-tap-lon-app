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
    progress.recordAnswers(_session.outcomes());
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
    final message = unanswered == 0 ? s.allAnswered : s.unansweredWarning(unanswered);
    _dialogOpen = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.submitQuestion),
        content: Text(
          fromBack
              ? '${s.cannotLeaveExam}\n\n$message'
              : message,
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

    return PopScope(
      canPop: false, // chỉ thoát được bằng cách nộp bài (hoặc khi hết giờ)
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _submit(fromBack: true);
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(s.exam),
        actions: [
          LanguageToggle(language: lang, onChanged: settings.setLanguage),
          TextButton(onPressed: _submit, child: Text(s.submit)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          ExamTimerBar(
            remaining: _countdown.remaining(now),
            warning: _countdown.isWarning(now),
            answered: _session.answeredCount,
            total: total,
          ),
          LinearProgressIndicator(
            value: (_index + 1) / total,
            semanticsLabel: s.questionPosition,
          ),
          Expanded(
            child: ListView(
              key: ValueKey(_index),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.examQuestionHeader(_index + 1, total),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    BookmarkButton(questionId: q.id),
                  ],
                ),
                QuestionText(q.questionFor(lang)),
                const SizedBox(height: 12),
                for (var i = 0; i < options.length; i++)
                  OptionTile(
                    letter: 'ABCD'[i],
                    text: options[i],
                    state: selected == i ? OptionState.selected : OptionState.idle,
                    onTap: () => setState(() => _session.answer(q, i)),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                      child: Text(s.previous),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _index == total - 1 ? null : () => setState(() => _index++),
                      child: Text(s.next),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
