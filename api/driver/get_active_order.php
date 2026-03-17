<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$driver_id = $_GET['driver_id'];

// Tìm đơn có driver_id này và chưa hoàn thành/hủy
$sql = "SELECT o.*, u.name as customer_name, u.phone as customer_phone 
        FROM orders o 
        JOIN users u ON o.customer_id = u.id
        WHERE o.driver_id = $driver_id AND o.status IN ('accepted', 'picking', 'delivering') 
        LIMIT 1";

$result = $conn->query($sql);
if ($result->num_rows > 0) {
    echo json_encode(["status" => "success", "data" => $result->fetch_assoc()]);
} else {
    echo json_encode(["status" => "empty"]);
}
?>