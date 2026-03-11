<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->name) && !empty($data->email) && !empty($data->phone) && !empty($data->password)) {
    
    $name = $conn->real_escape_string($data->name);
    $email = $conn->real_escape_string($data->email);
    $phone = $conn->real_escape_string($data->phone);
    $password_raw = $data->password;
    $role = 'customer'; // Mặc định theo yêu cầu

    // 1. KIỂM TRA TRÙNG LẶP (Email hoặc Phone)
    $checkQuery = "SELECT id FROM users WHERE email = '$email' OR phone = '$phone' LIMIT 1";
    $result = $conn->query($checkQuery);

    if ($result->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Email hoặc Số điện thoại đã tồn tại"]);
    } else {
        // 2. BĂM MẬT KHẨU (Bảo mật tuyệt đối)
        $hashed_password = password_hash($password_raw, PASSWORD_BCRYPT);

        // 3. LƯU VÀO DATABASE
        $sql = "INSERT INTO users (name, email, phone, password, role) 
                VALUES ('$name', '$email', '$phone', '$hashed_password', '$role')";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode([
                "status" => "success", 
                "message" => "Đăng ký thành công"
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Lỗi SQL: " . $conn->error]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Dữ liệu gửi lên không đầy đủ"]);
}

$conn->close();
?>