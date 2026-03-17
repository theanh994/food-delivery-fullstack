<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$data = json_decode(file_get_contents("php://input"));

$order_id = $data->order_id;
$sender_id = $data->sender_id;
$message = $conn->real_escape_string($data->message);

$sql = "INSERT INTO order_chats (order_id, sender_id, message) VALUES ($order_id, $sender_id, '$message')";

if ($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
?>