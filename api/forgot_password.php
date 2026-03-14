<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$email = $conn->real_escape_string($data->email);

$result = $conn->query("SELECT id FROM users WHERE email = '$email'");

if($result->num_rows > 0) {
    // Trong thực tế, đoạn này sẽ gửi mail thật qua PHPMailer
    echo json_encode([
        "status" => "success", 
        "message" => "Mã xác thực đã được gửi đến email của bạn",
        "otp" => "123456" // Trả về để Flutter hiện thông báo cho dễ test
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Email này chưa được đăng ký trên hệ thống"]);
}
$conn->close();
?>