<?php
$host = "localhost";
$user = "root"; 
$pass = "";     
$dbname = "food_delivery_db"; 
date_default_timezone_set('Asia/Ho_Chi_Minh');

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Lỗi kết nối DB"]));
}
$conn->set_charset("utf8mb4");
?>