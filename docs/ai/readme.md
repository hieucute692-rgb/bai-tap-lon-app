# Báo cáo sử dụng công cụ AI hỗ trợ phát triển dự án

## 1. Công cụ sử dụng
- **Gemini:** Phân tích lỗi runtime, tư vấn cấu trúc UI/UX màn hình chính và soạn thảo prompt kỹ thuật.
- **OpenAI Codex (VS Code):** Hỗ trợ sinh mã nguồn Dart/Flutter và tái cấu trúc giao diện theo yêu cầu.

## 2. Phạm vi áp dụng trong dự án

### 2.1. Thiết kế lại bố cục Trang chủ (`lib/presentation/home_screen.dart`)
- **Mục đích:** Tối ưu mật độ hiển thị để toàn bộ thông tin (Header, thanh tìm kiếm, thẻ tiến độ, lưới chức năng 3x2) hiển thị gọn trên một khung hình mà không bị cắt mép.
- **Prompt tiêu biểu:**
  > *"Tinh chỉnh giao diện trang chủ `home_screen.dart`: thêm đường Divider ngăn cách phần thống kê tổng 300 câu với Mục tiêu hôm nay + Streak; chỉnh `childAspectRatio: 1.15` và `mainAxisSpacing: 12` cho lưới chức năng chính 3x2."*
- **Kiểm chứng của nhóm:** Chạy kiểm thử trực tiếp trên trình duyệt Chrome/Edge ở nhiều kích thước cửa sổ, tự điều chỉnh lại khoảng cách dọc (`SizedBox`) để không che khuất phần Header.

### 2.2. Xây dựng các tính năng ôn tập bổ sung
- **Mục đích:** Bổ sung tính năng Học nhanh (Quick Study), Tra cứu nhanh 300 câu hỏi (Global Search) và Mục tiêu hằng ngày / Chuỗi ngày học (Daily Goal & Streak).
- **Kiểm chứng của nhóm:** Kiểm tra luồng điều hướng giữa các màn hình, đối chiếu dữ liệu đếm số câu đúng/sai thực tế từ ngân hàng 300 câu hỏi.

### 2.3. Xử lý lỗi tương thích đa nền tảng (`kIsWeb`)
- **Mục đích:** Khắc phục lỗi `MissingPluginException` của thư viện `path_provider` (`getApplicationDocumentsDirectory`) khi triển khai ứng dụng lên Flutter Web / Firebase Hosting.
- **Prompt tiêu biểu:**
  > *"Thêm kiểm tra điều kiện `kIsWeb`: trên Web bỏ qua `path_provider` và `dart:io`, đọc dữ liệu trực tiếp từ `rootBundle.loadString` và lưu tiến độ qua `SharedPreferences`; giữ nguyên logic lưu file trên Mobile/Desktop."*
- **Kiểm chứng của nhóm:** Dùng `git diff` rà soát từng dòng thay đổi, chạy `flutter analyze`, kiểm thử trên cả Edge/Chrome và đóng gói thành công lên Firebase Hosting.

## 3. Cam kết
Toàn bộ mã nguồn do AI gợi ý đều được các thành viên trong nhóm đọc hiểu, kiểm thử độc lập và chỉnh sửa để đảm bảo tính đồng nhất của toàn bộ ứng dụng.