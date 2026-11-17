/// Nơi lưu danh sách mã các câu hỏi người dùng đã đánh dấu.
abstract class BookmarkRepository {
  Future<Set<int>> loadBookmarks();
  Future<void> saveBookmarks(Set<int> ids);
}
