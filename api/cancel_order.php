<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$order_id = $data->order_id;

// 1. Lấy thông tin thời gian tạo đơn
$order_query = $conn->query("SELECT created_at, customer_id FROM orders WHERE id = $order_id AND status = 'pending'");
$order = $order_query->fetch_assoc();

if ($order) {
    $created_at = strtotime($order['created_at']);
    $current_time = time();
    $diff_seconds = $current_time - $created_at;

    // --- KIỂM TRA GIỚI HẠN 2 PHÚT (120 giây) ---
    if ($diff_seconds > 120) {
        echo json_encode(["status" => "error", "message" => "Đã quá thời gian 2 phút để tự hủy. Vui lòng gọi hotline!"]);
        exit;
    }

    // 2. Nếu còn trong 2 phút thì mới tiến hành hủy
    $customer_id = $order['customer_id'];
    $sql = "UPDATE orders SET status = 'cancelled' WHERE id = $order_id";
    
    if ($conn->query($sql)) {
        // Ghi thông báo hủy đơn
        $conn->query("INSERT INTO notifications (user_id, title, message) VALUES ($customer_id, 'Đơn hàng đã hủy', 'Bạn đã hủy đơn #EPC-$order_id thành công.')");
        echo json_encode(["status" => "success", "message" => "Hủy đơn thành công"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Không tìm thấy đơn hàng hoặc đơn đã được nhận."]);
}
?>