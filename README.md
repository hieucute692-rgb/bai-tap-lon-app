# Ôn tập Flutter — 300 câu trắc nghiệm song ngữ (INT1449, chủ đề 32)

## Mục đích
App ôn tập 300 câu trắc nghiệm Flutter song ngữ Anh – Việt, chia thành 20 khối kiến thức.
Giao diện theo hướng A (sáng, thẻ lưới; màu và độ tương phản khai báo trong `lib/presentation/app_theme.dart`).
Đã có: nạp dữ liệu từ JSON, luyện tập theo khối (đúng/sai và giải thích ngay), thi thử bốc đề theo tỉ lệ các khối,
thống kê theo khối, làm lại câu sai, xem lại chi tiết từng lần thi trong lịch sử thống kê (đáp án đã chọn, đáp án đúng, giải thích, lọc câu sai), đánh dấu câu hỏi (nút đánh dấu khi luyện tập, thi thử và ở danh sách câu sai; mục Đánh dấu để xem lại và luyện tập lại các câu đã lưu), giao diện hai ngôn ngữ Việt/Anh: chọn ngôn ngữ hiển thị ngay ở trang chủ (đổi cả chữ trên giao diện lẫn nội dung câu hỏi), được nhớ sau khi thoát app, vẫn đổi nhanh được khi làm bài,
đồng hồ đếm ngược khi thi thử (90 giây/câu, 30 câu = 45 phút; hết giờ tự nộp), và khóa thoát khi đang thi: chỉ ra khỏi bài thi được bằng cách nộp bài hoặc hết giờ.
Lưu ý: chữ do hệ thống Android tạo ra (ví dụ gợi ý của nút quay lại) vẫn theo ngôn ngữ của điện thoại.

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
- `lib/domain/app_strings.dart`: toàn bộ chữ giao diện, mỗi chuỗi có đủ bản Việt và Anh.
- `lib/domain/exam.dart`, `practice_session.dart`, `progress_stats.dart`: logic thuần Dart (bốc đề, chấm, thống kê) có unit test.

## Dữ liệu lưu ở đâu
Ngân hàng câu hỏi nằm trong assets của app. Các câu đã đánh dấu (danh sách mã câu) cũng lưu ở đây. Tiến độ làm bài (mỗi câu: số lượt, số lượt đúng, lần gần nhất đúng/sai;
và tối đa 20 lần thi gần nhất, kèm đáp án đã chọn của từng câu) lưu cục bộ trên máy bằng shared_preferences, không gửi đi đâu.
Lựa chọn ngôn ngữ cũng lưu ở đây. Dữ liệu chỉ tối đa 300 bản ghi nhỏ nên không cần cơ sở dữ liệu. App không dùng khoá API và không xin quyền hệ thống.

## Dùng AI
Công cụ: Claude. Hỗ trợ: dựng khung project, model/repository và test ban đầu. Hội thoại quan trọng lưu trong `docs/ai/`.
