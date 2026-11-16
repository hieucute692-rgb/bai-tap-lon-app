import 'package:flutter/foundation.dart';

import '../domain/question_bank.dart';
import '../domain/question_repository.dart';

enum LoadStatus { loading, ready, error }

/// Giữ trạng thái nạp ngân hàng câu hỏi (đang tải / sẵn sàng / lỗi).
class QuestionBankController extends ChangeNotifier {
  QuestionBankController(this._repository);

  final QuestionRepository _repository;

  LoadStatus _status = LoadStatus.loading;
  QuestionBank? _bank;
  String? _errorMessage;
  bool _disposed = false;

  LoadStatus get status => _status;
  QuestionBank? get bank => _bank;
  String? get errorMessage => _errorMessage;

  /// Nạp (hoặc nạp lại) dữ liệu. Dùng cho cả lần đầu và nút "Thử lại".
  Future<void> load() async {
    final wasLoading = _status == LoadStatus.loading;
    _status = LoadStatus.loading;
    _errorMessage = null;
    if (!wasLoading) notifyListeners();

    try {
      _bank = await _repository.load();
      _status = LoadStatus.ready;
    } catch (e, st) {
      debugPrint('Không nạp được ngân hàng câu hỏi: $e\n$st');
      _errorMessage = 'Không tải được ngân hàng câu hỏi.';
      _status = LoadStatus.error;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
