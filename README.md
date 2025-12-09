# Expense Manager (Quản lý Chi Tiêu Cá Nhân)

Dự án Web Application quản lý tài chính cá nhân, hỗ trợ người dùng theo dõi các khoản Thu/Chi hằng ngày và lập kế hoạch Tiết kiệm hiệu quả.

## Tính năng chính

* **Quản lý Thu/Chi:** Thêm, sửa, xóa và theo dõi lịch sử giao dịch hằng ngày.
* **Báo cáo Thống kê:** Hiển thị biểu đồ và số liệu chi tiết về dòng tiền theo Ngày/Tháng/Năm.
* **Quản lý Tiết kiệm (Saving):** Thiết lập các mục tiêu tích lũy, theo dõi tiến độ gửi và rút tiền từ các quỹ.
* **Cài đặt nâng cao:** Cho phép tùy chỉnh ngày bắt đầu của tháng tài chính (Custom Start Day).
* **Bảo mật:** Hệ thống xác thực người dùng và mã hóa mật khẩu.

## Công nghệ sử dụng

* **Backend:** Java Servlet, JSP, JSTL.
* **Build Tool:** Maven.
* **Database:** MySQL.
* **Database Connection:** HikariCP (Connection Pool) để tối ưu hiệu năng.
* **Frontend:** HTML5, CSS3, JavaScript (Responsive).
* **IDE:** **IntelliJ IDEA Ultimate**

## Hướng dẫn Cài đặt & Chạy dự án

Vui lòng thực hiện theo các bước sau để triển khai dự án trên môi trường cục bộ (Localhost).

### Bước 1: Clone dự án về máy
Mở Terminal hoặc Command Prompt và chạy lệnh sau:
git clone [https://github.com/grayzy2617/Expense-Manager.git](https://github.com/grayzy2617/Expense-Manager.git)

Bước 2: Cấu hình Cơ sở dữ liệu (Database)
+ Mở hệ quản trị cơ sở dữ liệu MySQL (ví dụ: phpMyAdmin hoặc MySQL Workbench).
+ Tạo một database mới có tên: expense_manager.
+ Import file database.sql (nằm trong thư mục gốc của dự án sau khi clone) .

Bước 3: Cấu hình Kết nối
+ Mở dự án bằng IntelliJ IDEA Ultimate.
+ Tìm đến file cấu hình kết nối tại đường dẫn: src/main/java/Database/ConnectionDb.java.
+ Cập nhật thông tin username và password của MySQL tương ứng với cấu hình máy cá nhân của bạn:

Bước 4: Chạy ứng dụng với Tomcat
+ Trong IntelliJ IDEA Ultimate, thêm cấu hình chạy mới (Add Configuration).
+ Chọn Tomcat Server -> Local.
+ Trong tab Deployment, bấm dấu + và chọn Artifact: Expense-Manager:war exploded.

Nhấn Apply và Run.

Trình duyệt sẽ tự động mở trang web (hoặc truy cập thủ công tại http://localhost:8080/).
