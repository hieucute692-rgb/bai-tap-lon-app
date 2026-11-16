import 'question_bank.dart';

/// Nguồn dữ liệu câu hỏi. Giao diện và logic chỉ phụ thuộc lớp trừu tượng này,
/// nên test có thể thay bằng bản giả và sau này đổi nguồn không phải sửa UI.
abstract class QuestionRepository {
  Future<QuestionBank> load();
}
