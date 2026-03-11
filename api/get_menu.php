<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_connect.php';

// 1. Lấy danh mục đang hoạt động
$cat_sql = "SELECT id, name, image_url FROM categories WHERE status = 'active'";
$cat_res = $conn->query($cat_sql);
$categories = [];
while($row = $cat_res->fetch_assoc()) {
    $categories[] = $row;
}

// 2. Lấy món ăn còn hàng
$food_sql = "SELECT id, category_id, food_type, name, description, price, image_url FROM foods WHERE is_available = 1";
$food_res = $conn->query($food_sql);
$foods = [];
while($row = $food_res->fetch_assoc()) {
    $foods[] = $row;
}

echo json_encode([
    "status" => "success",
    "categories" => $categories,
    "foods" => $foods
]);

$conn->close();
?>