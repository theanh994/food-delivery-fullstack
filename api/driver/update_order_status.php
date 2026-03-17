<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once '../db_connect.php';

// 1. Nhận dữ liệu từ Flutter
$data = json_decode(file_get_contents("php://input"));

if (!empty($data->order_id) && !empty($data->status)) {
    $order_id = $conn->real_escape_string($data->order_id);
    $new_status = $conn->real_escape_string($data->status);

    // 2. Cập nhật trạng thái đơn hàng trong bảng orders
    $sql = "UPDATE orders SET status = '$new_status' WHERE id = $order_id";

    if ($conn->query($sql)) {
        
        // 3. TỰ ĐỘNG TẠO THÔNG BÁO CHO KHÁCH HÀNG
        // Lấy customer_id của đơn hàng này
        $order_info = $conn->query("SELECT customer_id FROM orders WHERE id = $order_id")->fetch_assoc();
        $customer_id = $order_info['customer_id'];

        $noti_title = "Cập nhật đơn hàng";
        $noti_msg = "";

        // Soạn nội dung dựa trên trạng thái mới
        switch ($new_status) {
            case 'delivering':
                $noti_msg = "Tài xế đã lấy món và đang trên đường giao đến bạn.";
                break;
            case 'completed':
                $noti_msg = "Đơn hàng #EPC-$order_id đã được giao thành công. Chúc bạn ngon miệng!";
                break;
            case 'picking':
                $noti_msg = "Tài xế đang kiểm tra món ăn tại nhà hàng.";
                break;
            default:
                $noti_msg = "Đơn hàng của bạn đã chuyển sang trạng thái: $new_status";
                break;
        }

        if (!empty($noti_msg)) {
            $sql_noti = "INSERT INTO notifications (user_id, title, message) VALUES ($customer_id, '$noti_title', '$noti_msg')";
            $conn->query($sql_noti);
        }

        echo json_encode([
            "status" => "success",
            "message" => "Đã cập nhật trạng thái đơn hàng lên: $new_status"
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi SQL: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Dữ liệu gửi lên không đầy đủ"]);
}

$conn->close();
?>