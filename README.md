# Ôn tập Flutter — 300 câu trắc nghiệm song ngữ (INT1449, chủ đề 32)

## Mục đích
App ôn tập 300 câu trắc nghiệm Flutter song ngữ Anh – Việt, chia thành 20 khối kiến thức.
Hiện đã có: nạp dữ liệu từ JSON, danh sách khối, xem câu hỏi (kể cả đoạn mã).
Chưa làm: luyện tập, thi thử, thống kê, làm lại câu sai, chọn ngôn ngữ, đồng hồ đếm ngược.

## Cài đặt
```bash
flutter create . --platforms=android --project-name flutter_quiz_300
flutter pub get
```
Chạy `flutter create` khi chưa commit gì để `git diff` cho thấy nó có ghi đè tệp nào không.

## Chạy và kiểm thử
```bash
flutter run
flutter analyze
flutter test
```

## Cấu trúc
- `lib/domain`: model (`Question`, `QuestionBank`), `QuestionRepository` (trừu tượng), tách đoạn mã.
- `lib/data`: `AssetQuestionRepository` đọc `assets/data/questions.json`.
- `lib/presentation`: controller (`ChangeNotifier` + Provider) và các màn hình.

## Dữ liệu lưu ở đâu
Ngân hàng câu hỏi nằm trong assets của app. Chưa lưu dữ liệu người dùng; khi thêm lịch sử làm bài
sẽ lưu cục bộ bằng SQLite trên máy, không gửi đi đâu. App không dùng khoá API và không xin quyền hệ thống.

## Dùng AI
Công cụ: Claude. Hỗ trợ: dựng khung project, model/repository và test ban đầu. Hội thoại quan trọng lưu trong `docs/ai/`.
