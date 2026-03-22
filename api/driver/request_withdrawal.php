<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->driver_id) && !empty($data->amount)) {
    $driver_id = $data->driver_id;
    $amount = (float)$data->amount;

    // 1. Kiểm tra số dư ví xem có đủ rút không
    $wallet = $conn->query("SELECT balance FROM driver_wallets WHERE driver_id = $driver_id")->fetch_assoc();
    
    if ($wallet && $wallet['balance'] >= $amount) {
        // 2. Tạo yêu cầu rút tiền ở trạng thái pending
        $sql = "INSERT INTO withdrawal_requests (driver_id, amount, status) VALUES ($driver_id, $amount, 'pending')";
        
        if ($conn->query($sql)) {
            echo json_encode(["status" => "success", "message" => "Yêu cầu rút tiền đã được gửi. Vui lòng chờ Admin duyệt."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Lỗi hệ thống: " . $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Số dư trong ví không đủ để thực hiện giao dịch."]);
    }
}
?>