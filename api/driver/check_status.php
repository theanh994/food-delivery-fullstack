<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$user_id = $_GET['user_id'];

$sql = "SELECT status FROM driver_profiles WHERE user_id = $user_id";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode(["status" => "success", "driver_status" => $row['status']]);
} else {
    // Chưa có bản ghi -> unverified
    echo json_encode(["status" => "success", "driver_status" => "unverified"]);
}
$conn->close();
?>