<?php
$host = "localhost";
$user = "root"; // User mặc định của XAMPP
$pass = "";     // Pass mặc định của XAMPP
$dbname = "food_delivery_db"; // Tên database bạn đã tạo

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Lỗi kết nối DB"]));
}
$conn->set_charset("utf8mb4");
?>