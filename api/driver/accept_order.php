<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$order_id = $data->order_id;
$driver_id = $data->driver_id;

// Ràng buộc: Chỉ UPDATE nếu driver_id vẫn đang NULL (ngừa trường hợp 2 tài xế cùng bấm 1 lúc)
$sql = "UPDATE orders SET driver_id = $driver_id, status = 'accepted' 
        WHERE id = $order_id AND driver_id IS NULL";

if ($conn->query($sql) && $conn->affected_rows > 0) {
    // Tạo thông báo cho khách hàng
    $conn->query("INSERT INTO notifications (user_id, title, message) 
                  SELECT customer_id, 'Đã tìm thấy tài xế', 'Tài xế đã nhận đơn hàng của bạn và đang đến quán.' 
                  FROM orders WHERE id = $order_id");
    
    echo json_encode(["status" => "success", "message" => "Nhận đơn thành công!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Rất tiếc, đơn hàng này đã có người khác nhận."]);
}
?>