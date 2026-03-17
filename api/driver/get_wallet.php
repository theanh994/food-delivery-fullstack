<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once '../db_connect.php';

$driver_id = $_GET['driver_id'];

// Lấy số dư
$wallet = $conn->query("SELECT balance FROM driver_wallets WHERE driver_id = $driver_id")->fetch_assoc();
$balance = $wallet ? (float)$wallet['balance'] : 0.0;

// Lấy 20 giao dịch gần nhất
$res = $conn->query("SELECT * FROM wallet_transactions WHERE driver_id = $driver_id ORDER BY created_at DESC LIMIT 20");
$transactions = [];
while($row = $res->fetch_assoc()) {
    $row['amount'] = (float)$row['amount'];
    $transactions[] = $row;
}

echo json_encode([
    "status" => "success",
    "balance" => $balance,
    "transactions" => $transactions
]);
?>