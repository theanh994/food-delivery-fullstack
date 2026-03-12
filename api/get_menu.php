<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_connect.php';

// 1. Lấy Categories
$cat_res = $conn->query("SELECT * FROM categories WHERE status = 'active'");
$categories = [];
while($row = $cat_res->fetch_assoc()) { $categories[] = $row; }

// 2. Lấy Foods và các OptionGroups lồng bên trong
$food_res = $conn->query("SELECT * FROM foods WHERE is_available = 1");
$foods = [];

while($food = $food_res->fetch_assoc()) {
    $food_id = $food['id'];
    
    // Lấy các nhóm tùy chọn của món này
    $group_res = $conn->query("SELECT * FROM option_groups WHERE food_id = $food_id");
    $option_groups = [];
    
    while($group = $group_res->fetch_assoc()) {
        $group_id = $group['id'];
        
        // Lấy các item trong từng nhóm
        $item_res = $conn->query("SELECT name, extra_price FROM option_items WHERE group_id = $group_id");
        $options = [];
        while($item = $item_res->fetch_assoc()) {
            $options[] = [
                "name" => $item['name'],
                "extra_price" => (float)$item['extra_price']
            ];
        }
        
        $group['options'] = $options;
        $option_groups[] = $group;
    }
    
    $food['option_groups'] = $option_groups;
    $foods[] = $food;
}

echo json_encode([
    "status" => "success",
    "categories" => $categories,
    "foods" => $foods
]);
?>