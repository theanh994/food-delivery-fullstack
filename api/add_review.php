<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->order_id) && !empty($data->rating)) {
    $order_id = $data->order_id;
    
    // Check xem đơn hàng đã hoàn thành chưa mới cho đánh giá
    $check = $conn->query("SELECT status FROM orders WHERE id = $order_id")->fetch_assoc();
    
    if ($check['status'] == 'completed') {
        $customer_id = $data->customer_id;
        $food_id = $data->food_id;
        $rating = $data->rating;
        $comment = $conn->real_escape_string($data->comment);

        $sql = "INSERT INTO reviews (order_id, customer_id, food_id, rating, comment) 
                VALUES ($order_id, $customer_id, $food_id, $rating, '$comment')";
        
        if ($conn->query($sql)) {
            echo json_encode(["status" => "success", "message" => "Cảm ơn bạn đã đánh giá!"]);
        } else {
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Bạn chỉ có thể đánh giá đơn hàng đã hoàn thành."]);
    }
}
?>