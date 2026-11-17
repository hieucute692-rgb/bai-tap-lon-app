# Ôn tập Flutter — 300 câu trắc nghiệm song ngữ (INT1449, chủ đề 32)

## Mục đích
App ôn tập 300 câu trắc nghiệm Flutter song ngữ Anh – Việt, chia thành 20 khối kiến thức.
Đã có: nạp dữ liệu từ JSON, luyện tập theo khối (đúng/sai và giải thích ngay), thi thử bốc đề theo tỉ lệ các khối,
thống kê theo khối, làm lại câu sai, nút đổi nhanh VI/EN khi làm bài.
Chưa làm: lưu lựa chọn ngôn ngữ và giao diện hai ngôn ngữ, đồng hồ đếm ngược.

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
- `lib/domain/exam.dart`, `practice_session.dart`, `progress_stats.dart`: logic thuần Dart (bốc đề, chấm, thống kê) có unit test.

## Dữ liệu lưu ở đâu
Ngân hàng câu hỏi nằm trong assets của app. Tiến độ làm bài (mỗi câu: số lượt, số lượt đúng, lần gần nhất đúng/sai;
và tối đa 20 lần thi gần nhất) lưu cục bộ trên máy bằng shared_preferences, không gửi đi đâu.
Dữ liệu chỉ tối đa 300 bản ghi nhỏ nên không cần cơ sở dữ liệu. App không dùng khoá API và không xin quyền hệ thống.

## Dùng AI
Công cụ: Claude. Hỗ trợ: dựng khung project, model/repository và test ban đầu. Hội thoại quan trọng lưu trong `docs/ai/`.
