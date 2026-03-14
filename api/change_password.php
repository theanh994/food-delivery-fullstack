<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$user_id = $data->user_id;
$old_pass = $data->old_password;
$new_pass = password_hash($data->new_password, PASSWORD_BCRYPT);

$user = $conn->query("SELECT password FROM users WHERE id = $user_id")->fetch_assoc();

if (password_verify($old_pass, $user['password'])) {
    $conn->query("UPDATE users SET password = '$new_pass' WHERE id = $user_id");
    echo json_encode(["status" => "success", "message" => "Đổi mật khẩu thành công"]);
} else {
    echo json_encode(["status" => "error", "message" => "Mật khẩu cũ không chính xác"]);
}
?>