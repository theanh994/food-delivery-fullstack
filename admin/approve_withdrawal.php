<?php
require_once '../api/db_connect.php';

$id = (int)$_GET['id'];
$action = $_GET['action'];

if ($action == 'reject') {
    $conn->query("UPDATE withdrawal_requests SET status = 'rejected' WHERE id = $id");
    header("Location: withdrawals.php"); exit;
}

if ($action == 'approve') {
    // BẮT ĐẦU TRANSACTION TÀI CHÍNH
    $conn->begin_transaction();
    try {
        // 1. Lấy thông tin Yêu cầu (Khóa dòng này lại để tránh Race Condition)
        $req = $conn->query("SELECT driver_id, amount FROM withdrawal_requests WHERE id = $id AND status = 'pending' FOR UPDATE")->fetch_assoc();
        if(!$req) throw new Exception("Yêu cầu không hợp lệ hoặc đã xử lý.");
        
        $driver_id = $req['driver_id'];
        $amount = $req['amount'];

        // 2. Kiểm tra số dư ví có đủ không
        $wallet = $conn->query("SELECT balance FROM driver_wallets WHERE driver_id = $driver_id FOR UPDATE")->fetch_assoc();
        if($wallet['balance'] < $amount) throw new Exception("Số dư tài xế không đủ để rút.");

        // 3. Trừ tiền ví
        $conn->query("UPDATE driver_wallets SET balance = balance - $amount WHERE driver_id = $driver_id");

        // 4. Ghi lịch sử giao dịch
        $conn->query("INSERT INTO wallet_transactions (driver_id, amount, type, description) VALUES ($driver_id, $amount, 'withdrawal', 'Rút tiền về tài khoản ngân hàng')");

        // 5. Cập nhật trạng thái Yêu cầu
        $conn->query("UPDATE withdrawal_requests SET status = 'approved' WHERE id = $id");

        // 6. Hoàn tất
        $conn->commit();
    } catch (Exception $e) {
        $conn->rollback();
        die("LỖI GIAO DỊCH: " . $e->getMessage());
    }
    header("Location: withdrawals.php"); exit;
}
?>