<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->customer_id) && !empty($data->items)) {
    
    // BẮT ĐẦU TRANSACTION
    $conn->begin_transaction();

    try {
        $customer_id = $data->customer_id;
        $total_amount = $data->total_amount;
        $shipping_fee = $data->shipping_fee;
        $final_amount = $data->final_amount;
        $address = $conn->real_escape_string($data->delivery_address);
        $note = $conn->real_escape_string($data->order_note);

        // 1. Chèn vào bảng orders
        $sql_order = "INSERT INTO orders (customer_id, total_amount, shipping_fee, final_amount, delivery_address, order_note, status) 
                      VALUES ($customer_id, $total_amount, $shipping_fee, $final_amount, '$address', '$note', 'pending')";
        
        if (!$conn->query($sql_order)) {
            throw new Exception("Lỗi chèn đơn hàng: " . $conn->error);
        }

        $order_id = $conn->insert_id;

        // 2. Chèn chi tiết từng món vào order_details
        foreach ($data->items as $item) {
            $food_id = $item->food_id;
            $qty = $item->quantity;
            $price = $item->unit_price;
            $item_note = $conn->real_escape_string($item->item_note);

            $sql_detail = "INSERT INTO order_details (order_id, food_id, quantity, unit_price, item_note) 
                           VALUES ($order_id, $food_id, $qty, $price, '$item_note')";
            
            if (!$conn->query($sql_detail)) {
                throw new Exception("Lỗi chèn chi tiết món: " . $conn->error);
            }
        }

        // 3. Tự động tạo thông báo cho khách hàng
        $msg_title = "Đặt hàng thành công";
        $msg_body = "Đơn hàng #EPC-$order_id của bạn đã được tiếp nhận và đang chờ xác nhận.";
        $sql_noti = "INSERT INTO notifications (user_id, title, message) VALUES ($customer_id, '$msg_title', '$msg_body')";
        $conn->query($sql_noti);

        // 4. Lưu vĩnh viễn
        $conn->commit();
        echo json_encode(["status" => "success", "message" => "Đặt hàng thành công", "order_id" => $order_id]);

    } catch (Exception $e) {
        // Nếu có lỗi, hủy bỏ toàn bộ các lệnh INSERT ở trên
        $conn->rollback();
        echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    }

} else {
    echo json_encode(["status" => "error", "message" => "Dữ liệu không hợp lệ"]);
}

$conn->close();
?>