<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$user_id = $_POST['user_id'];
$v_type = $conn->real_escape_string($_POST['vehicle_type']);
$v_plate = $conn->real_escape_string($_POST['vehicle_plate']);

$target_dir = "../../uploads/drivers/";
if (!file_exists($target_dir)) mkdir($target_dir, 0777, true);

// Xử lý 2 file
$license_path = "";
$portrait_path = "";

if (isset($_FILES['license_image'])) {
    $name = "license_" . $user_id . "_" . time() . ".jpg";
    if (move_uploaded_file($_FILES["license_image"]["tmp_name"], $target_dir . $name)) $license_path = "uploads/drivers/" . $name;
}

if (isset($_FILES['portrait_image'])) {
    $name = "portrait_" . $user_id . "_" . time() . ".jpg";
    if (move_uploaded_file($_FILES["portrait_image"]["tmp_name"], $target_dir . $name)) $portrait_path = "uploads/drivers/" . $name;
}

$sql = "REPLACE INTO driver_profiles (user_id, vehicle_type, vehicle_plate, license_image, portrait_image, status) 
        VALUES ($user_id, '$v_type', '$v_plate', '$license_path', '$portrait_path', 'pending')";

if ($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
?>