<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_connect.php';

$customer_id = $_GET['customer_id'];

// Lấy danh sách đơn hàng
$sql = "SELECT * FROM orders WHERE customer_id = $customer_id ORDER BY created_at DESC";
$result = $conn->query($sql);

$orders = [];
while($row = $result->fetch_assoc()) {
    $order_id = $row['id'];
    
    // Lấy chi tiết từng món trong đơn này
    $detail_sql = "SELECT d.*, f.name as food_name 
                   FROM order_details d 
                   JOIN foods f ON d.food_id = f.id 
                   WHERE d.order_id = $order_id";
    $detail_res = $conn->query($detail_sql);
    
    $details = [];
    while($d = $detail_res->fetch_assoc()) {
        $details[] = $d;
    }
    
    $row['details'] = $details;
    $orders[] = $row;
}

echo json_encode(["status" => "success", "data" => $orders]);
$conn->close();
?>