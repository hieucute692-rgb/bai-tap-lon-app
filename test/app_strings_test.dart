import 'package:flutter_quiz_300/domain/app_strings.dart';
import 'package:flutter_quiz_300/domain/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const vi = AppStrings(ContentLanguage.vi);
  const en = AppStrings(ContentLanguage.en);

  test('chuỗi đơn giản có đủ hai ngôn ngữ', () {
    expect(vi.practice, 'Luyện tập');
    expect(en.practice, 'Practice');
    expect(vi.exam, 'Thi thử');
    expect(en.exam, 'Mock exam');
    expect(vi.displayLanguage, 'Ngôn ngữ hiển thị');
    expect(en.displayLanguage, 'Display language');
  });

  test('chuỗi có tham số', () {
    expect(vi.questionsAndBlocks(300, 20), '300 câu · 20 khối kiến thức');
    expect(en.questionsAndBlocks(300, 20), '300 questions · 20 knowledge blocks');
    expect(vi.blockTitle(3, 'Cách Flutter hoạt động'), 'Khối 3. Cách Flutter hoạt động');
    expect(en.blockTitle(3, 'How Flutter works'), 'Block 3. How Flutter works');
    expect(vi.correctOf(24, 30), 'Đúng 24/30 câu');
    expect(en.correctOf(24, 30), 'Correct 24/30');
    expect(vi.timeLeft('45:00'), 'Còn lại 45:00');
    expect(en.timeLeft('45:00'), 'Time left 45:00');
  });

  test('chuỗi mục đánh dấu', () {
    expect(vi.bookmarks, 'Đánh dấu');
    expect(en.bookmarks, 'Bookmarks');
    expect(vi.bookmarkedCount(5), '5 câu đã đánh dấu');
    expect(en.bookmarkedCount(5), '5 bookmarked');
  });

  test('chuỗi thống kê nhiều tham số', () {
    expect(
      vi.blockStatsLine(percent: 75, correct: 15, attempts: 20, answered: 12, total: 20, wrong: 3),
      'Đúng 75% (15/20 lượt) · Đã làm 12/20 · Đang sai 3',
    );
    expect(
      en.blockStatsLine(percent: 75, correct: 15, attempts: 20, answered: 12, total: 20, wrong: 3),
      'Correct 75% (15/20 attempts) · Done 12/20 · Wrong 3',
    );
  });

  test('hai ngôn ngữ khác nhau ở các chuỗi chính, và không chuỗi nào rỗng', () {
    final pairs = <(String, String)>[
      (vi.appTitle, en.appTitle),
      (vi.retry, en.retry),
      (vi.explanation, en.explanation),
      (vi.next, en.next),
      (vi.submit, en.submit),
      (vi.stats, en.stats),
      (vi.retryWrong, en.retryWrong),
      (vi.examRules, en.examRules),
      (vi.timedOutNote, en.timedOutNote),
      (vi.cannotLeaveExam, en.cannotLeaveExam),
      (vi.bookmarks, en.bookmarks),
      (vi.examDetailTitle, en.examDetailTitle),
      (vi.filterWrong, en.filterWrong),
      (vi.examDetailUnavailable, en.examDetailUnavailable),
      (vi.bookmarksEmptyHint, en.bookmarksEmptyHint),
      (vi.bookmarkSaveProblem, en.bookmarkSaveProblem),
      (vi.progressSaveProblem, en.progressSaveProblem),
    ];
    for (final (a, b) in pairs) {
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a, isNot(b));
    }
  });
}
