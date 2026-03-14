<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$user_id = $_GET['user_id'];
$sql = "SELECT * FROM notifications WHERE user_id = $user_id ORDER BY created_at DESC";
$result = $conn->query($sql);

$notis = [];
while($row = $result->fetch_assoc()) {
    $notis[] = $row;
}

echo json_encode(["status" => "success", "data" => $notis]);
?>