<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

error_reporting(0); 

$user_id = $_POST['user_id'];
$name = $conn->real_escape_string($_POST['name']);
$phone = $conn->real_escape_string($_POST['phone']);
$avatar_url = "";

// Xử lý upload ảnh nếu có
if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] == 0) {
    $target_dir = "../uploads/avatars/";
    if (!file_exists($target_dir)) mkdir($target_dir, 0777, true);
    
    $file_ext = pathinfo($_FILES["avatar"]["name"], PATHINFO_EXTENSION);
    $file_name = "user_" . $user_id . "_" . time() . "." . $file_ext;
    $target_file = $target_dir . $file_name;

    if (move_uploaded_file($_FILES["avatar"]["tmp_name"], $target_file)) {
        $avatar_path = "uploads/avatars/" . $file_name;
        // Gán giá trị nếu có ảnh
        $avatar_sql = ", avatar = '$avatar_path'"; 
    }
}

$sql = "UPDATE users SET name = '$name', phone = '$phone' $avatar_sql WHERE id = $user_id";

if ($conn->query($sql)) {
    $updated_user = $conn->query("SELECT * FROM users WHERE id = $user_id")->fetch_assoc();
    unset($updated_user['password']);

    echo json_encode([
        "status" => "success", 
        "message" => "Cập nhật thành công", 
        "data" => $updated_user]);
} else {
    echo json_encode([
        "status" => "error", 
        "message" => $conn->error]);
}
$conn->close();
?>