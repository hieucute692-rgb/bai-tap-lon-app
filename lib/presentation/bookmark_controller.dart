import 'package:flutter/foundation.dart';

import '../domain/bookmark_repository.dart';
import 'question_bank_controller.dart';

/// Loại sự cố khi đọc/ghi danh sách đánh dấu; giao diện tự đổi thành câu chữ theo ngôn ngữ.
enum BookmarkProblem { loadFailed, saveFailed }

/// Giữ các câu đã đánh dấu. Đổi trạng thái là có hiệu lực ngay trong bộ nhớ; ghi xuống máy
/// lỗi thì app vẫn dùng được và [problem] cho giao diện biết để báo người dùng.
class BookmarkController extends ChangeNotifier {
  BookmarkController(this._repository);

  final BookmarkRepository _repository;

  LoadStatus _status = LoadStatus.loading;
  Set<int> _ids = <int>{};
  BookmarkProblem? _problem;
  bool _disposed = false;

  LoadStatus get status => _status;
  Set<int> get ids => Set.unmodifiable(_ids);
  int get count => _ids.length;
  BookmarkProblem? get problem => _problem;

  bool isBookmarked(int questionId) => _ids.contains(questionId);

  Future<void> load() async {
    try {
      _ids = await _repository.loadBookmarks();
      _problem = null;
    } catch (e, st) {
      debugPrint('Không đọc được danh sách đánh dấu: $e\n$st');
      _ids = <int>{};
      _problem = BookmarkProblem.loadFailed;
    }
    _status = LoadStatus.ready;
    _notify();
  }

  /// Đánh dấu nếu chưa có, bỏ đánh dấu nếu đã có.
  Future<void> toggle(int questionId) async {
    final next = Set<int>.of(_ids);
    if (!next.remove(questionId)) next.add(questionId);
    _ids = next;
    _notify();
    try {
      await _repository.saveBookmarks(_ids);
    } catch (e, st) {
      debugPrint('Không lưu được danh sách đánh dấu: $e\n$st');
      _problem = BookmarkProblem.saveFailed;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
