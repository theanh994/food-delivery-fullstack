<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$order_id = $_GET['order_id'];

$sql = "SELECT * FROM order_chats WHERE order_id = $order_id ORDER BY created_at ASC";
$result = $conn->query($sql);

$messages = [];
while($row = $result->fetch_assoc()) {
    $messages[] = $row;
}

echo json_encode(["status" => "success", "data" => $messages]);
?>