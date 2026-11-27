import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/practice_session.dart';
import '../domain/question.dart';
import 'progress_controller.dart';
import 'settings_controller.dart';
import 'strings_context.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/explanation_card.dart';
import 'widgets/language_toggle.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_text.dart';

/// Tiêu đề màn hình, tính lại mỗi lần vẽ để đổi theo ngôn ngữ đang chọn.
typedef PracticeTitle = String Function(AppStrings strings);

/// Luyện tập: chọn đáp án là biết đúng sai ngay, kèm giải thích.
/// Dùng chung cho luyện theo khối và "làm lại câu sai".
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.titleOf,
    required this.questions,
  });

  final PracticeTitle titleOf;
  final List<Question> questions;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeSession _session = PracticeSession(widget.questions);
  bool _finished = false;

  void _select(int option) {
    final isCorrect = _session.select(option);
    if (isCorrect == null) return;
    setState(() {});
    context
        .read<ProgressController>()
        .recordAnswers({_session.current.id: isCorrect});
  }

  void _next() {
    setState(() {
      if (_session.isLast) {
        _finished = true;
      } else {
        _session.next();
      }
    });
  }

  OptionState _stateOf(int i, Question q, int? chosen) {
    if (chosen == null) return OptionState.idle;
    if (i == q.correctIndex) return OptionState.correct;
    if (i == chosen) return OptionState.wrong;
    return OptionState.idle;
  }

  // Mở bottom sheet dạng lưới giúp chuyển nhanh giữa các câu trong phiên luyện tập.
  Future<void> _openQuestionNavigator(int total) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: total,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (_, i) {
                final isCurrent = i == _session.index;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(sheetContext).pop(i),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isCurrent
                            ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        )
                            : null,
                        color: isCurrent
                            ? null
                            : (isDark ? scheme.surfaceContainerHigh : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? Colors.white
                              : (isDark
                              ? Colors.white10
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
                              : (isDark
                              ? scheme.onSurface
                              : const Color(0xFF334155)),
                          fontWeight:
                          isCurrent ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    // Nhảy tới chỉ số câu người dùng vừa chọn.
    if (selectedIndex != null && mounted) {
      setState(() => _session.index = selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final lang = settings.language;
    final s = settings.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    if (_finished) {
      return _PracticeSummary(
        correct: _session.correctCount,
        total: _session.questions.length,
      );
    }

    final q = _session.current;
    final chosen = _session.chosen;
    final options = q.optionsFor(lang);
    final total = _session.questions.length;
    final progressValue =
    total == 0 ? 0.0 : ((_session.index + 1) / total).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.titleOf(s),
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          LanguageToggle(language: lang, onChanged: settings.setLanguage),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Semantics(
              label: s.practiceProgress,
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
                  key: ValueKey(_session.index),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? scheme.surfaceContainer : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color:
                          isDark ? Colors.white10 : const Color(0xFFE8ECF7),
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
                                onTap: () => _openQuestionNavigator(total),
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
                                        s.practiceQuestionHeader(
                                          _session.index + 1,
                                          total,
                                          q.blockId,
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
                        state: _stateOf(i, q, chosen),
                        onTap: chosen == null ? () => _select(i) : null,
                      ),
                    if (chosen != null) ...[
                      const SizedBox(height: 8),
                      ExplanationCard(text: q.explanationFor(lang)),
                    ],
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: chosen == null
                            ? null
                            : const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        color: chosen == null
                            ? (isDark
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFFE2E8F0))
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: chosen == null
                            ? null
                            : [
                          BoxShadow(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: chosen == null ? null : _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _session.isLast ? s.finish : s.next,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: chosen == null
                                ? const Color(0xFF94A3B8)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeSummary extends StatelessWidget {
  const _PracticeSummary({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.practiceResultTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: isDark
                  ? null
                  : const LinearGradient(
                colors: [
                  Color(0xFFEEF4FF),
                  Color(0xFFFDFDFF),
                  Color(0xFFF3EEFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: isDark ? scheme.surfaceContainerHigh : null,
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.white,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A44), Color(0xFFFF3D77)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.correctOf(correct, total),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        s.backToHome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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
    );
  }
}