<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'db_connect.php';

// Nhận dữ liệu JSON từ Flutter gửi lên
$data = json_decode(file_get_contents("php://input"));

if (!empty($data->email) && !empty($data->password)) {
    $email = $conn->real_escape_string($data->email);
    $password = $data->password;

    // Tìm user theo email
    $sql = "SELECT * FROM users WHERE email = '$email' LIMIT 1";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        
        // Kiểm tra mật khẩu
        if (password_verify($password, $user['password'])) {
            
            // --- [MỚI CẬP NHẬT]: CHỐT CHẶN KIỂM TRA TÀI KHOẢN BỊ KHÓA ---
            // Kiểm tra xem cột is_banned có tồn tại và bằng 1 hay không
            if (isset($user['is_banned']) && $user['is_banned'] == 1) {
                echo json_encode([
                    "status" => "error", 
                    "message" => "Tài khoản của bạn đã bị khóa do vi phạm chính sách của hệ thống."
                ]);
                exit; // Dừng chương trình ngay lập tức, không cho đăng nhập
            }
            // -----------------------------------------------------------

            // Xóa password khỏi response để bảo mật khi truyền về Flutter
            unset($user['password']);

            echo json_encode([
                "status" => "success",
                "message" => "Đăng nhập thành công",
                "data" => $user
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Sai mật khẩu"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Email không tồn tại"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Vui lòng nhập đủ email và mật khẩu"]);
}

$conn->close();
?>