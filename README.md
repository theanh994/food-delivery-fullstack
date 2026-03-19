# 🍔 Ứng dụng Giao đồ ăn (Food Delivery App) - Hướng dẫn Cài đặt & Thiết lập

Chào mừng bạn đến với dự án **Food Delivery**! Dự án này bao gồm 3 thành phần chính:

1. **Ứng dụng Di động (Flutter)** (`food_delivery_app/`)
2. **Backend API (PHP)** (`api/`)
3. **Trang Quản trị Web (PHP)** (`admin/`)

Tài liệu này sẽ hướng dẫn bạn cách thiết lập và chạy dự án trên máy tính cá nhân.

---

## 📋 Yêu cầu hệ thống

Trước khi bắt đầu, hãy đảm bảo bạn đã cài đặt các phần mềm sau:

- **XAMPP / WAMP / MAMP**: Để chạy Apache (máy chủ PHP) và MySQL (Cơ sở dữ liệu).
- **Composer**: Trình quản lý thư viện cho PHP (cần thiết cho API).
- **Flutter SDK**: Phiên bản 3.10.4 trở lên (kèm theo Dart SDK).
- **Android Studio / VS Code**: Để chạy ứng dụng Flutter.

---

## 🚀 Các bước Cài đặt

### 1. Thiết lập Cơ sở dữ liệu

1. Mở **XAMPP Control Panel** và khởi động **Apache** cùng **MySQL**.
2. Mở trình duyệt và truy cập vào `http://localhost/phpmyadmin/`.
3. Tạo một cơ sở dữ liệu mới với tên là **`food_delivery_db`**.
4. Chọn tab **Import (Nhập)**, tải lên file **`food_delivery_db.sql`** (đã có sẵn trong thư mục dự án) và tiến hành import để nạp dữ liệu.

### 2. Thiết lập Backend API (`api/`)

API xử lý toàn bộ logic backend và thông báo Firebase.

1. Đảm bảo toàn bộ thư mục dự án (`DoAn_FoodDelivery`) được đặt trong thư mục `xampp/htdocs/`.
2. Mở terminal và di chuyển đến thư mục `api/`:

   ```bash
   cd c:\xampp\htdocs\DoAn_FoodDelivery\api
   ```

3. Cài đặt các thư viện PHP thông qua Composer:

   ```bash
   composer install
   ```

4. Kiểm tra file kết nối cơ sở dữ liệu tại `api/db_connect.php`. Mặc định cấu hình như sau:

   - Host: `localhost`
   - User: `root`
   - Password: `""` (để trống)
   - DB Name: `food_delivery_db`

*(Lưu ý: File `api/service-account.json` được sử dụng cho cấu hình Firebase Cloud Messaging. Vui lòng bảo mật và không xóa file này).*

### 3. Thiết lập Trang Quản trị (Admin Panel) (`admin/`)

Trang quản trị Web cho phép quản lý người dùng, đơn hàng, món ăn, v.v.

1. Trang Quản trị dùng chung file kết nối Cơ sở dữ liệu với API (`api/db_connect.php`).
2. Bạn có thể truy cập trang Quản trị thông qua trình duyệt tại địa chỉ:

   ```text
   http://localhost/DoAn_FoodDelivery/admin/
   ```

### 4. Thiết lập Ứng dụng Flutter (`food_delivery_app/`)

Ứng dụng frontend trên thiết bị di động được xây dựng bằng Flutter.

1. Mở terminal và di chuyển đến thư mục chứa mã nguồn Flutter:

   ```bash
   cd c:\xampp\htdocs\DoAn_FoodDelivery\food_delivery_app
   ```

2. Tải các thư viện (dependencies) của Flutter:

   ```bash
   flutter pub get
   ```

3. Kết nối với máy ảo Android/iOS hoặc thiết bị thật.
4. Chạy ứng dụng:

   ```bash
   flutter run
   ```

---

## 🛠️ Thay đổi Base URL API trong Flutter

Nếu backend của bạn được lưu trữ online hoặc IP máy tính thay đổi:

1. Tìm cấu hình URL API trong mã nguồn Flutter (thường nằm trong thư mục `lib/` hoặc các file cấu hình).
2. Đổi địa chỉ API thành IP mạng LAN hiện tại của bạn (ví dụ: `http://192.168.1.x/DoAn_FoodDelivery/api/`) hoặc domain thật. Lý do là vì máy ảo Android không thể gọi `localhost` trực tiếp để vào XAMPP của máy tính (thường dùng `10.0.2.2`).

---

## ✅ Kiểm tra lại lần cuối

- **Bảng điều khiển Admin** tải thành công trên trình duyệt.
- **Các API endpoints** hoạt động bình thường (thử truy cập `http://localhost/DoAn_FoodDelivery/api/get_menu.php`).
- **Ứng dụng Flutter** biên dịch không lỗi và kết nối đúng với backend máy bạn.

Cảm ơn bạn đã xem qua dự án này!
