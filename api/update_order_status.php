<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$order_id = $data->order_id;
$new_status = $data->status; // 'accepted', 'delivering', 'completed'

// 1. Cập nhật trạng thái đơn
$sql = "UPDATE orders SET status = '$new_status' WHERE id = $order_id";

if ($conn->query($sql)) {
    // 2. Tự động lấy customer_id để bắn thông báo
    $order = $conn->query("SELECT customer_id FROM orders WHERE id = $order_id")->fetch_assoc();
    $cust_id = $order['customer_id'];

    $msg = "";
    if($new_status == 'completed') $msg = "Đơn hàng #EPC-$order_id đã giao thành công. Chúc bạn ngon miệng!";
    if($new_status == 'delivering') $msg = "Tài xế đang trên đường giao đơn hàng #EPC-$order_id cho bạn.";
    
    if($msg != "") {
        $conn->query("INSERT INTO notifications (user_id, title, message) VALUES ($cust_id, 'Cập nhật đơn hàng', '$msg')");
    }

    echo json_encode(["status" => "success", "message" => "Đã cập nhật trạng thái và bắn thông báo"]);
}
?>