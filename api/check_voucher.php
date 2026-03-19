<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));
$code = $conn->real_escape_string($data->code);
$total_amount = (float)$data->total_amount;

$sql = "SELECT * FROM vouchers WHERE code = '$code' AND status = 'active' LIMIT 1";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $v = $result->fetch_assoc();
    $now = date('Y-m-d H:i:s');

    if ($now > $v['expiry_date']) {
        echo json_encode(["status" => "error", "message" => "Mã này đã hết hạn"]);
    } elseif ($v['used_count'] >= $v['usage_limit']) {
        echo json_encode(["status" => "error", "message" => "Mã này đã hết lượt sử dụng"]);
    } elseif ($total_amount < $v['min_spend']) {
        echo json_encode(["status" => "error", "message" => "Đơn hàng tối thiểu phải từ " . number_format($v['min_spend']) . "đ"]);
    } else {
        echo json_encode([
            "status" => "success", 
            "discount" => (float)$v['discount_amount'],
            "message" => "Áp dụng mã thành công!"
        ]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Mã giảm giá không hợp lệ"]);
}
$conn->close();
?>