<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$order_id = $data->order_id;

// Chỉ được hủy nếu status là pending
$sql = "UPDATE orders SET status = 'cancelled' WHERE id = $order_id AND status = 'pending'";

if ($conn->query($sql) === TRUE && $conn->affected_rows > 0) {
    echo json_encode(["status" => "success", "message" => "Hủy đơn thành công"]);
} else {
    echo json_encode(["status" => "error", "message" => "Không thể hủy đơn hàng này"]);
}
$conn->close();
?>