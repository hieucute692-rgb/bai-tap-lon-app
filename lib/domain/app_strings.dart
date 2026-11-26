import 'question.dart';

/// Toàn bộ chữ trên giao diện, hai ngôn ngữ. Mỗi chuỗi khai báo cả bản Việt lẫn bản Anh
/// ngay cạnh nhau qua [_t], nên không thể có chuỗi thiếu một ngôn ngữ.
class AppStrings {
  const AppStrings(this.language);

  final ContentLanguage language;

  String get appearance => _t('Giao diện', 'Appearance');
  String get themeLight => _t('Sáng', 'Light');
  String get themeSystem => _t('Tự động', 'System');
  String get themeDark => _t('Tối', 'Dark');

  String _t(String vi, String en) => language == ContentLanguage.vi ? vi : en;

  // ---- Chung ----
  String get appTitle => _t('Ôn tập Flutter', 'Flutter Review');
  String get retry => _t('Thử lại', 'Try again');
  String get reload => _t('Tải lại', 'Reload');
  String get backToHome => _t('Về trang chủ', 'Back to home');
  String get explanation => _t('Giải thích', 'Explanation');
  String get next => _t('Câu tiếp', 'Next');
  String get previous => _t('Câu trước', 'Previous');
  String blockTitle(int id, String name) => _t('Khối $id. $name', 'Block $id. $name');
  String questionCount(int n) => _t('$n câu', '$n questions');
  String correctOf(int correct, int total) =>
      _t('Đúng $correct/$total câu', 'Correct $correct/$total');

  // ---- Trang chủ ----
  String get bankLoadError =>
      _t('Không tải được ngân hàng câu hỏi.', 'Could not load the question bank.');
  String get noQuestions => _t('Chưa có câu hỏi nào.', 'There are no questions yet.');
  String questionsAndBlocks(int questions, int blocks) => _t(
        '$questions câu · $blocks khối kiến thức',
        '$questions questions · $blocks knowledge blocks',
      );
  String get displayLanguage => _t('Ngôn ngữ hiển thị', 'Display language');
  String get practice => _t('Luyện tập', 'Practice');
  String get quickStudy => _t('Học nhanh', 'Quick study');
  String get quickStudySubtitle => _t('Ôn nhanh lý thuyết cốt lõi · 20 khối', 'Review core theory · 20 blocks');
  String get quickStudyAll => _t('Tất cả câu trong khối', 'All questions in block');
  String get quickStudyBookmarked => _t('Chỉ câu đã đánh dấu', 'Bookmarked only');
  String get quickStudyEmpty => _t('Chưa có câu nào được đánh dấu trong khối này.', 'No bookmarked questions in this block yet.');
  String get quickStudyAnswer => _t('Đáp án đúng', 'Correct answer');
  String get searchQuestions => _t('Tra cứu nhanh', 'Quick search');
  String get searchPrompt => _t('Tìm từ khóa, khái niệm Flutter...', 'Search keywords, Flutter concepts...');
  String get searchHomePrompt => _t('Tra cứu nhanh 300 câu hỏi...', 'Search 300 questions...');
  String get searchAllBlocks => _t('Tất cả', 'All');
  String get searchShowAnswers => _t('Hiện đáp án', 'Show answers');
  String get searchFound => _t('Tìm thấy', 'Found');
  String get searchResults => _t('câu hỏi', 'questions');
  String get searchEmpty => _t('Không tìm thấy câu hỏi phù hợp.', 'No matching questions found.');
  String get searchHint => _t('Nhập từ khóa hoặc thử một gợi ý bên dưới.', 'Enter a keyword or try a suggestion below.');
  String get practiceSubtitle => _t(
        'Làm theo khối, biết đúng sai và xem giải thích ngay',
        'Practice by block with instant feedback and explanations',
      );
  String get exam => _t('Thi thử', 'Mock exam');
  String get examShort => _t('Chấm khi nộp bài', 'Graded on submit');
  String get stats => _t('Thống kê', 'Statistics');
  String get statsShort => _t('Theo từng khối', 'By block');
  String get retryWrong => _t('Làm lại câu sai', 'Retry wrong answers');
  String get noWrongSubtitle => _t('Chưa có câu sai', 'No wrong answers');
  String wrongCount(int n) => _t('$n câu đang sai', '$n wrong');
  String get noWrongYet => _t(
        'Chưa có câu sai nào. Hãy luyện tập hoặc thi thử trước.',
        'No wrong answers yet. Practice or take a mock exam first.',
      );

  // ---- Xem lại chi tiết bài thi ----
  String get examDetailTitle => _t('Chi tiết bài thi', 'Exam details');
  String get filterAll => _t('Tất cả', 'All');
  String get filterWrong => _t('Câu sai', 'Wrong only');
  String get statusCorrect => _t('Đúng', 'Correct');
  String get statusWrong => _t('Sai', 'Wrong');
  String get statusUnanswered => _t('Bỏ trống', 'Unanswered');
  String get examDetailUnavailable => _t(
        'Không có chi tiết cho bài thi này (bài được lưu bởi phiên bản cũ của app).',
        'No details are available for this exam (it was saved by an older version of the app).',
      );
  String get tapToReview => _t('Bấm để xem lại chi tiết', 'Tap to review details');

  // ---- Đánh dấu ----
  String get bookmarks => _t('Đánh dấu', 'Bookmarks');
  String get bookmarksSubtitle =>
      _t('Các câu bạn đã đánh dấu để xem lại', 'Questions you saved to review later');
  String get noBookmarksSubtitle => _t('Chưa có câu nào', 'None yet');
  String bookmarkedCount(int n) => _t('$n câu đã đánh dấu', '$n bookmarked');
  String get bookmarkTooltip => _t('Đánh dấu câu này', 'Bookmark this question');
  String get removeBookmark => _t('Bỏ đánh dấu', 'Remove bookmark');
  String get bookmarksEmpty =>
      _t('Chưa có câu nào được đánh dấu.', 'No bookmarked questions yet.');
  String get bookmarksEmptyHint => _t(
        'Bấm biểu tượng đánh dấu khi luyện tập hoặc thi thử để lưu câu vào đây.',
        'Tap the bookmark icon while practicing or taking a mock exam to save a question here.',
      );
  String get practiceBookmarked =>
      _t('Luyện tập các câu đã đánh dấu', 'Practice bookmarked questions');
  String get bookmarkedQuestionsTitle => _t('Câu đã đánh dấu', 'Bookmarked questions');
  String get bookmarkLoadProblem => _t(
        'Không đọc được các câu đã đánh dấu trên máy.',
        'Could not read the bookmarks saved on this device.',
      );
  String get bookmarkSaveProblem => _t(
        'Không lưu được các câu đã đánh dấu; chúng sẽ mất khi thoát app.',
        'Could not save bookmarks; they will be lost when you leave the app.',
      );
  String get goBack => _t('Quay lại', 'Go back');

  // ---- Luyện tập ----
  String get practiceAll => _t('Luyện tập tất cả', 'Practice all');
  String get allBlocks => _t('Tất cả các khối', 'All blocks');
  String practiceDone(int done, int total) => _t('Đã làm $done/$total', 'Done $done/$total');
  String get practiceProgress => _t('Tiến độ luyện tập', 'Practice progress');
  String practiceQuestionHeader(int index, int total, int blockId) =>
      _t('Câu $index/$total · Khối $blockId', 'Question $index/$total · Block $blockId');
  String get finish => _t('Hoàn tất', 'Finish');
  String get practiceResultTitle => _t('Kết quả luyện tập', 'Practice results');

  // ---- Thi thử ----
  String get questionCountLabel => _t('Số câu', 'Number of questions');
  String timeLimit(int minutes) =>
      _t('Thời gian làm bài: $minutes phút', 'Time limit: $minutes minutes');
  String get examRules => _t(
        'Câu hỏi được bốc ngẫu nhiên, số câu mỗi khối tỉ lệ với số câu của khối đó. '
            'Đáp án chỉ hiện sau khi nộp bài; câu bỏ trống tính là sai. '
            'Hết giờ, bài được nộp tự động.',
        'Questions are drawn at random, with the number per block proportional to the '
            'block size. Answers are shown only after you submit; unanswered questions '
            'count as wrong. When time runs out, the exam is submitted automatically.',
      );
  String get start => _t('Bắt đầu', 'Start');
  String get submit => _t('Nộp bài', 'Submit');
  String get submitQuestion => _t('Nộp bài?', 'Submit exam?');
  String get allAnswered => _t('Bạn đã trả lời hết các câu.', 'You have answered all questions.');
  String unansweredWarning(int n) => _t(
        'Còn $n câu chưa trả lời, sẽ tính là sai.',
        '$n unanswered; they will count as wrong.',
      );
  String get keepGoing => _t('Làm tiếp', 'Keep going');
  String get cannotLeaveExam => _t(
        'Bạn đang làm bài thi nên chưa thể thoát. Hãy nộp bài để kết thúc.',
        'You are in the middle of an exam and cannot leave yet. Submit to finish.',
      );
  String examQuestionHeader(int index, int total) =>
      _t('Câu $index/$total', 'Question $index/$total');
  String get questionPosition => _t('Vị trí câu hỏi', 'Question position');
  String timeLeft(String time) => _t('Còn lại $time', 'Time left $time');
  String almostOutOfTime(String time) =>
      _t('Sắp hết giờ, còn lại $time', 'Almost out of time, $time left');
  String answeredOf(int answered, int total) =>
      _t('Đã trả lời $answered/$total', 'Answered $answered/$total');

  // ---- Kết quả thi thử ----
  String get examResultTitle => _t('Kết quả thi thử', 'Mock exam results');
  String scoreOf(String score) => _t('Điểm: $score/10', 'Score: $score/10');
  String get timedOutNote => _t(
        'Hết giờ, bài đã được nộp tự động.',
        'Time is up; the exam was submitted automatically.',
      );
  String get allCorrect =>
      _t('Bạn trả lời đúng tất cả các câu.', 'You answered every question correctly.');
  String wrongOrUnanswered(int n) => _t('Các câu sai hoặc bỏ trống ($n)', 'Wrong or unanswered ($n)');
  String questionLabel(int id) => _t('Câu $id', 'Question $id');
  String get notAnswered => _t('Bạn chưa trả lời.', 'You did not answer.');
  String youChose(String letter, String text) =>
      _t('Bạn chọn: $letter. $text', 'Your answer: $letter. $text');
  String correctAnswer(String letter, String text) =>
      _t('Đáp án đúng: $letter. $text', 'Correct answer: $letter. $text');

  // ---- Thống kê ----
  String get statsEmpty => _t('Bạn chưa làm câu nào.', 'You have not answered any questions yet.');
  String get statsBack => _t('Quay lại để bắt đầu', 'Go back to start');
  String statsAnswered(int answered, int total) =>
      _t('Đã làm $answered/$total câu', 'Answered $answered/$total questions');
  String statsAccuracy(int percent, int correct, int attempts) => _t(
        'Tỉ lệ đúng: $percent% ($correct/$attempts lượt)',
        'Accuracy: $percent% ($correct/$attempts attempts)',
      );
  String accuracyForBlock(int id) => _t('Tỉ lệ đúng khối $id', 'Accuracy for block $id');
  String blockNotStarted(int total) => _t('Chưa làm · $total câu', 'Not started · $total questions');
  String blockStatsLine({
    required int percent,
    required int correct,
    required int attempts,
    required int answered,
    required int total,
    required int wrong,
  }) =>
      _t(
        'Đúng $percent% ($correct/$attempts lượt) · Đã làm $answered/$total · Đang sai $wrong',
        'Correct $percent% ($correct/$attempts attempts) · Done $answered/$total · Wrong $wrong',
      );
  String get examHistory => _t('Lịch sử thi thử', 'Mock exam history');
  String get examStats => _t('Thống kê thi thử', 'Mock exam statistics');
  String get examCount => _t('Số lần thi', 'Exams taken');
  String get examAverageScore => _t('Điểm trung bình', 'Average score');
  String get examBestScore => _t('Điểm cao nhất', 'Best score');
  String get examLatestScore => _t('Lần gần nhất', 'Latest score');
  String examHistoryEntry(int correct, int total, String score) =>
      _t('$correct/$total câu · $score/10', '$correct/$total questions · $score/10');
  String get progressLoadProblem => _t(
        'Không đọc được tiến độ đã lưu trên máy.',
        'Could not read the progress saved on this device.',
      );
  String get progressSaveProblem => _t(
        'Không lưu được tiến độ trên máy; kết quả sẽ mất khi thoát app.',
        'Could not save progress on this device; results will be lost when you leave the app.',
      );
}
