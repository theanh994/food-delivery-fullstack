<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';
require_once '../firebase_helper.php'; // Đã có file này

$data = json_decode(file_get_contents("php://input"));
$order_id = $data->order_id;
$driver_id = $data->driver_id;

// 1. Logic cũ: Cập nhật trạng thái trong MySQL (Giữ nguyên)
$sql = "UPDATE orders SET driver_id = $driver_id, status = 'accepted' 
        WHERE id = $order_id AND driver_id IS NULL";

if ($conn->query($sql) && $conn->affected_rows > 0) {
    
    $res = $conn->query("SELECT fcm_token FROM users WHERE id = (SELECT customer_id FROM orders WHERE id = $order_id)")->fetch_assoc();
    if (!empty($res['fcm_token'])) {
        FirebaseHelper::sendNotification($res['fcm_token'], "Đã tìm thấy tài xế! 🛵", "Tài xế đang đến quán lấy món cho bạn.");
    }

    // --- BẮT ĐẦU PHẦN THÊM MỚI (REAL-TIME PUSH) ---
    
    // 3. Lấy FCM Token của khách hàng để biết "gửi vào máy nào"
    $customer_query = "SELECT u.fcm_token 
                       FROM users u 
                       JOIN orders o ON u.id = o.customer_id 
                       WHERE o.id = $order_id LIMIT 1";
    $customer_res = $conn->query($customer_query)->fetch_assoc();

    // 4. Nếu khách hàng có Token (đang online) thì đẩy thông báo nổi lên điện thoại ngay
    if (!empty($customer_res['fcm_token'])) {
        FirebaseHelper::sendNotification(
            $customer_res['fcm_token'], 
            "Đã tìm thấy tài xế! 🛵", 
            "Tài xế Nguyễn Văn A đã nhận đơn #EPC-$order_id của bạn."
        );
    }

    // --- KẾT THÚC PHẦN THÊM MỚI ---
    
    echo json_encode(["status" => "success", "message" => "Nhận đơn thành công!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Rất tiếc, đơn hàng này đã có người khác nhận."]);
}
?>