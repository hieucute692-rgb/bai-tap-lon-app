import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import '../domain/exam.dart';
import '../domain/question.dart';
import '../domain/question_text.dart';
import 'settings_controller.dart';
import 'widgets/bookmark_button.dart';
import 'widgets/explanation_card.dart';
import 'widgets/language_toggle.dart';
import 'widgets/question_text.dart';

/// Kết quả thi thử: điểm, và danh sách câu sai kèm đáp án đúng, giải thích.
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({
    super.key,
    required this.session,
    this.timedOut = false,
  });

  final ExamSession session;

  /// Bài được nộp tự động vì hết giờ.
  final bool timedOut;

  String _firstLine(String text) {
    final segments = parseQuestionText(text);
    return segments.isEmpty ? '' : segments.first.content;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final lang = settings.language;
    final s = settings.strings;
    final total = session.questions.length;
    final correct = session.correctCount;
    final wrong = session.wrongQuestions;
    final score = total == 0 ? 0.0 : correct * 10 / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? scheme.surface : const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.examResultTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          LanguageToggle(language: lang, onChanged: settings.setLanguage),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.correctOf(correct, total),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.scoreOf(score.toStringAsFixed(1)),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (timedOut) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4E6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                s.timedOutNote,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: const Color(0xFFBE123C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A44), Color(0xFFFF3D77)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3D77)
                                .withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            score.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            '/10',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (wrong.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? scheme.surfaceContainer : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.allCorrect,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  s.wrongOrUnanswered(wrong.length),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                for (final q in wrong)
                  _WrongTile(
                    question: q,
                    chosen: session.answerOf(q),
                    lang: lang,
                    strings: s,
                    preview: _firstLine(q.questionFor(lang)),
                  ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
    );
  }
}

class _WrongTile extends StatelessWidget {
  const _WrongTile({
    required this.question,
    required this.chosen,
    required this.lang,
    required this.strings,
    required this.preview,
  });

  final Question question;
  final int? chosen;
  final ContentLanguage lang;
  final AppStrings strings;
  final String preview;

  @override
  Widget build(BuildContext context) {
    final options = question.optionsFor(lang);
    final right = question.correctIndex;
    final pick = chosen;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8ECF7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            strings.questionLabel(question.id),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E40AF),
            ),
          ),
          subtitle: Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: BookmarkButton(questionId: question.id),
            ),
            QuestionText(question.questionFor(lang)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pick == null
                    ? strings.notAnswered
                    : strings.youChose('ABCD'[pick], options[pick]),
                style: const TextStyle(
                  color: Color(0xFFBE123C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                strings.correctAnswer('ABCD'[right], options[right]),
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ExplanationCard(text: question.explanationFor(lang)),
          ],
        ),
      ),
    );
  }
}