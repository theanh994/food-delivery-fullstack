<?php
require_once 'db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(!empty($data->user_id) && !empty($data->fcm_token)) {
    $uid = $data->user_id;
    $token = $conn->real_escape_string($data->fcm_token);
    
    $conn->query("UPDATE users SET fcm_token = '$token' WHERE id = $uid");
    echo json_encode(["status" => "success"]);
}
?>