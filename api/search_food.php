<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$query = isset($_GET['query']) ? $conn->real_escape_string($_GET['query']) : '';

if ($query == '') {
    echo json_encode(["status" => "success", "data" => []]);
    exit;
}

// 1. Tìm món ăn theo tên (Dùng LIKE)
$sql = "SELECT f.*, c.name as category_name 
        FROM foods f 
        LEFT JOIN categories c ON f.category_id = c.id 
        WHERE f.name LIKE '%$query%' AND f.is_available = 1 
        ORDER BY f.name ASC";

$result = $conn->query($sql);
$foods = [];

while($food = $result->fetch_assoc()) {
    $food_id = $food['id'];
    
    // Lấy các nhóm tùy chọn (để khách bấm vào hiện modal chọn size/topping được ngay)
    $group_res = $conn->query("SELECT * FROM option_groups WHERE food_id = $food_id");
    $option_groups = [];
    while($group = $group_res->fetch_assoc()) {
        $g_id = $group['id'];
        $item_res = $conn->query("SELECT name, extra_price FROM option_items WHERE group_id = $g_id");
        $options = [];
        while($item = $item_res->fetch_assoc()) {
            $options[] = ["name" => $item['name'], "extra_price" => (float)$item['extra_price']];
        }
        $group['options'] = $options;
        $option_groups[] = $group;
    }
    
    $food['option_groups'] = $option_groups;
    $foods[] = $food;
}

echo json_encode(["status" => "success", "data" => $foods]);
?>