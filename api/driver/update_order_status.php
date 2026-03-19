<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once '../db_connect.php';
require_once '../firebase_helper.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->order_id) && !empty($data->status)) {
    $order_id = $conn->real_escape_string($data->order_id);
    $new_status = $conn->real_escape_string($data->status);

    // --- BƯỚC 1: BẮT ĐẦU TRANSACTION (GIAO DỊCH) ---
    $conn->begin_transaction();

    try {
        // 1. Cập nhật trạng thái đơn hàng
        $sql_update = "UPDATE orders SET status = '$new_status' WHERE id = $order_id";
        if (!$conn->query($sql_update)) {
            throw new Exception("Lỗi cập nhật trạng thái đơn hàng");
        }

        // 2. Lấy thông tin đơn hàng để xử lý tiền và thông báo
        $order_query = $conn->query("SELECT customer_id, driver_id, shipping_fee FROM orders WHERE id = $order_id");
        $order_info = $order_query->fetch_assoc();
        
        if (!$order_info) {
            throw new Exception("Không tìm thấy thông tin đơn hàng");
        }

        $customer_id = $order_info['customer_id'];
        $driver_id = $order_info['driver_id'];
        $amount = (float)$order_info['shipping_fee'];

        // --- BƯỚC 2: XỬ LÝ TÀI CHÍNH KHI ĐƠN HOÀN THÀNH ---
        if ($new_status == 'completed' && !empty($driver_id)) {
            // A. Cộng tiền vào ví tài xế (Nếu chưa có ví thì tạo mới)
            $sql_wallet = "INSERT INTO driver_wallets (driver_id, balance) VALUES ($driver_id, $amount) 
                           ON DUPLICATE KEY UPDATE balance = balance + $amount";
            if (!$conn->query($sql_wallet)) {
                throw new Exception("Lỗi cập nhật số dư ví tài xế");
            }

            // B. Ghi lại lịch sử giao dịch vào bảng wallet_transactions
            $desc = "Thu nhập từ đơn hàng #EPC-$order_id";
            $sql_log = "INSERT INTO wallet_transactions (driver_id, amount, type, description) 
                        VALUES ($driver_id, $amount, 'earning', '$desc')";
            if (!$conn->query($sql_log)) {
                throw new Exception("Lỗi ghi lịch sử giao dịch");
            }
        }

        // --- BƯỚC 3: TỰ ĐỘNG TẠO THÔNG BÁO CHO KHÁCH HÀNG ---
        $noti_title = "Cập nhật đơn hàng";
        $noti_msg = "";
        switch ($new_status) {
            case 'delivering': $noti_msg = "Tài xế đã lấy món và đang trên đường giao đến bạn."; break;
            case 'completed': $noti_msg = "Đơn hàng #EPC-$order_id đã được giao thành công. Chúc bạn ngon miệng!"; break;
            case 'picking': $noti_msg = "Tài xế đang kiểm tra món ăn tại nhà hàng."; break;
        }

        if (!empty($noti_msg)) {
            // A. Lưu vào lịch sử thông báo trong DB (như cũ)
            $sql_noti = "INSERT INTO notifications (user_id, title, message) VALUES ($customer_id, '$noti_title', '$noti_msg')";
            $conn->query($sql_noti);

            // B. [MỚI]: GỬI THÔNG BÁO REAL-TIME QUA FIREBASE
            // Lấy Token của khách hàng từ bảng users
            $user_res = $conn->query("SELECT fcm_token FROM users WHERE id = $customer_id")->fetch_assoc();
            if (!empty($user_res['fcm_token'])) {
                FirebaseHelper::sendNotification(
                    $user_res['fcm_token'], 
                    $noti_title, 
                    $noti_msg
                );
            }
        }

        // --- BƯỚC 4: HOÀN TẤT VÀ LƯU DỮ LIỆU (COMMIT) ---
        $conn->commit();

        echo json_encode([
            "status" => "success",
            "message" => "Cập nhật thành công đơn hàng và ví thu nhập"
        ]);

    } catch (Exception $e) {
        // NẾU CÓ BẤT KỲ LỖI NÀO -> HỦY BỎ TẤT CẢ CÁC LỆNH TRÊN
        $conn->rollback();
        echo json_encode([
            "status" => "error",
            "message" => $e->getMessage()
        ]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Dữ liệu không đầy đủ"]);
}

$conn->close();
?>