<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->user_id)) {
    $user_id = $data->user_id;

    // Cập nhật role trong bảng users
    $sql = "UPDATE users SET role = 'driver' WHERE id = $user_id";

    if ($conn->query($sql)) {
        // Lấy lại thông tin user mới nhất
        $user = $conn->query("SELECT * FROM users WHERE id = $user_id")->fetch_assoc();
        unset($user['password']);
        
        echo json_encode([
            "status" => "success", 
            "message" => "Đã nâng cấp lên tài khoản Đối tác",
            "data" => $user
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
$conn->close();
?>