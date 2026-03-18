<?php
require_once '../api/db_connect.php';

if (isset($_GET['id'])) {
    $profile_id = (int)$_GET['id'];
    
    // 1. Cập nhật trạng thái thành approved
    $sql = "UPDATE driver_profiles SET status = 'approved' WHERE id = $profile_id";
    
    if ($conn->query($sql)) {
        // 2. Bắn thông báo chúc mừng cho tài xế
        $user_query = $conn->query("SELECT user_id FROM driver_profiles WHERE id = $profile_id")->fetch_assoc();
        if ($user_query) {
            $user_id = $user_query['user_id'];
            $title = "Hồ sơ được duyệt!";
            $msg = "Chúc mừng bạn đã trở thành đối tác chính thức của Epicure. Bạn đã có thể bắt đầu nhận đơn!";
            $conn->query("INSERT INTO notifications (user_id, title, message) VALUES ($user_id, '$title', '$msg')");
        }
        
        // 3. Quay lại trang quản lý
        header("Location: drivers.php?msg=success");
        exit;
    } else {
        die("Lỗi hệ thống: " . $conn->error);
    }
} else {
    die("Thiếu ID hồ sơ.");
}
?>