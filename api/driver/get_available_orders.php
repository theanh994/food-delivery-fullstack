<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

// Lấy các đơn đang chờ và chưa có tài xế nào nhận
$sql = "SELECT o.*, u.name as customer_name, u.phone as customer_phone 
        FROM orders o 
        JOIN users u ON o.customer_id = u.id
        WHERE o.status = 'pending' AND o.driver_id IS NULL 
        ORDER BY o.created_at DESC";

$result = $conn->query($sql);
$orders = [];
while($row = $result->fetch_assoc()) {
    $row['id'] = (int)$row['id'];
    $row['customer_id'] = (int)$row['customer_id'];
    $row['total_amount'] = (float)$row['total_amount'];
    // ... các trường số khác
    $orders[] = $row;
}
echo json_encode(["status" => "success", "data" => $orders]);
?>