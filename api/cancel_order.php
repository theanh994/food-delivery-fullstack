<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->order_id)) {
    $order_id = $data->order_id;

    // 1. Tìm customer_id của đơn hàng này
    $order_query = $conn->query("SELECT customer_id FROM orders WHERE id = $order_id");
    $order_data = $order_query->fetch_assoc();

    if ($order_data) {
        $customer_id = $order_data['customer_id'];

        // 2. Cập nhật đơn hàng sang cancelled
        $update_sql = "UPDATE orders SET status = 'cancelled' WHERE id = $order_id AND status = 'pending'";
        
        if ($conn->query($update_sql) && $conn->affected_rows > 0) {
            
            // 3. TỰ ĐỘNG CHÈN THÔNG BÁO (Quan trọng nhất)
            $title = "Đơn hàng đã hủy";
            $msg = "Bạn đã hủy thành công đơn hàng #EPC-$order_id.";
            $conn->query("INSERT INTO notifications (user_id, title, message) VALUES ($customer_id, '$title', '$msg')");

            echo json_encode(["status" => "success", "message" => "Đã hủy và tạo thông báo"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Đơn hàng không ở trạng thái chờ hoặc đã bị xử lý"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Không tìm thấy đơn hàng"]);
    }
}
$conn->close();
?>