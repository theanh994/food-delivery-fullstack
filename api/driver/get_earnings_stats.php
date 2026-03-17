<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$driver_id = $_GET['driver_id'];

// 1. Thu nhập hôm nay
$today_res = $conn->query("SELECT SUM(amount) as total FROM wallet_transactions 
                           WHERE driver_id = $driver_id AND type = 'earning' 
                           AND DATE(created_at) = CURDATE()")->fetch_assoc();
$today_total = $today_res['total'] ?? 0;

// 2. Thu nhập tuần này (7 ngày qua)
$week_res = $conn->query("SELECT SUM(amount) as total FROM wallet_transactions 
                          WHERE driver_id = $driver_id AND type = 'earning' 
                          AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetch_assoc();
$week_total = $week_res['total'] ?? 0;

// 3. Dữ liệu biểu đồ (7 ngày gần nhất)
$chart_sql = "SELECT DATE(created_at) as date, SUM(amount) as amount 
              FROM wallet_transactions 
              WHERE driver_id = $driver_id AND type = 'earning' 
              GROUP BY DATE(created_at) 
              ORDER BY date ASC LIMIT 7";
$chart_res = $conn->query($chart_sql);
$chart_data = [];
while($row = $chart_res->fetch_assoc()) {
    $chart_data[] = [
        "day" => date('d/m', strtotime($row['date'])),
        "amount" => (float)$row['amount']
    ];
}

echo json_encode([
    "status" => "success",
    "today" => (float)$today_total,
    "week" => (float)$week_total,
    "chart" => $chart_data
]);
?>