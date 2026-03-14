<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$email = $conn->real_escape_string($data->email);

$result = $conn->query("SELECT id FROM users WHERE email = '$email'");
if($result->num_rows > 0) {
    echo json_encode([
        "status" => "success", 
        "message" => "Mã xác thực đã được gửi", 
        "otp" => "123456" // OTP giả lập để test UI
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Email không tồn tại trên hệ thống"]);
}
?>