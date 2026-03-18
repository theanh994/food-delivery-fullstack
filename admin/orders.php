<?php
require_once '../api/db_connect.php';

// --- XỬ LÝ BỘ LỌC ---
$status_filter = isset($_GET['status']) ? $conn->real_escape_string($_GET['status']) : '';
$date_filter = isset($_GET['order_date']) ? $conn->real_escape_string($_GET['order_date']) : '';

// Tạo câu truy vấn động (1=1 để nối chuỗi dễ dàng)
$sql = "SELECT o.*, c.name as customer_name, d.name as driver_name 
        FROM orders o 
        JOIN users c ON o.customer_id = c.id 
        LEFT JOIN users d ON o.driver_id = d.id 
        WHERE 1=1 ";

if ($status_filter != '') {
    $sql .= " AND o.status = '$status_filter' ";
}
if ($date_filter != '') {
    // Lọc theo ngày đặt (chỉ lấy phần YYYY-MM-DD)
    $sql .= " AND DATE(o.created_at) = '$date_filter' ";
}

$sql .= " ORDER BY o.created_at DESC";
$result = $conn->query($sql);

$page_title = "Quản lý Đơn hàng";
include 'includes/sidebar.php'; 
?>

<!-- KHUNG BỘ LỌC NÂNG CẤP -->
<div class="card shadow mb-4">
    <div class="card-body bg-light py-3">
        <form method="GET" action="orders.php" class="form-row align-items-center">
            <div class="col-md-3 mb-2">
                <label class="small font-weight-bold text-muted mb-1">Trạng thái</label>
                <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="pending" <?= $status_filter == 'pending' ? 'selected' : '' ?>>Đang chờ</option>
                    <option value="accepted" <?= $status_filter == 'accepted' ? 'selected' : '' ?>>Đã nhận đơn</option>
                    <option value="delivering" <?= $status_filter == 'delivering' ? 'selected' : '' ?>>Đang giao</option>
                    <option value="completed" <?= $status_filter == 'completed' ? 'selected' : '' ?>>Hoàn thành</option>
                    <option value="cancelled" <?= $status_filter == 'cancelled' ? 'selected' : '' ?>>Đã hủy</option>
                </select>
            </div>
            
            <div class="col-md-3 mb-2">
                <label class="small font-weight-bold text-muted mb-1">Ngày đặt</label>
                <input type="date" name="order_date" class="form-control" value="<?= htmlspecialchars($date_filter) ?>">
            </div>

            <div class="col-md-2 mb-2 mt-4">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-filter"></i> Lọc đơn</button>
            </div>
            
            <?php if($status_filter != '' || $date_filter != ''): ?>
            <div class="col-md-2 mb-2 mt-4">
                <a href="orders.php" class="btn btn-outline-danger w-100"><i class="fas fa-times"></i> Xóa lọc</a>
            </div>
            <?php endif; ?>
        </form>
    </div>
</div>

<div class="card shadow mb-4">
    <div class="card-body table-responsive">
        <?php if($result->num_rows > 0): ?>
            <table class="table table-bordered table-hover align-middle">
                <thead class="thead-light">
                    <tr>
                        <th class="text-center">STT</th>
                        <th>Mã ĐH</th>
                        <th>Khách hàng</th>
                        <th>Tài xế</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th>Ngày đặt</th>
                        <th class="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $stt = 1;
                    while($row = $result->fetch_assoc()): 
                        // Đổi màu badge theo trạng thái
                        $badge_class = 'secondary';
                        if($row['status'] == 'completed') $badge_class = 'success';
                        elseif($row['status'] == 'cancelled') $badge_class = 'danger';
                        elseif($row['status'] == 'pending') $badge_class = 'warning text-dark';
                        elseif($row['status'] == 'delivering') $badge_class = 'primary';
                    ?>
                    <tr>
                        <td class="text-center align-middle font-weight-bold"><?= $stt++ ?></td>
                        <td class="align-middle font-weight-bold">#EPC-<?= $row['id'] ?></td>
                        <td class="align-middle"><?= $row['customer_name'] ?></td>
                        <td class="align-middle"><?= $row['driver_name'] ?? '<span class="text-muted font-italic">Chưa có</span>' ?></td>
                        <td class="align-middle font-weight-bold text-danger"><?= number_format($row['final_amount']) ?>đ</td>
                        <td class="align-middle"><span class="badge badge-<?= $badge_class ?> px-2 py-1"><?= strtoupper($row['status']) ?></span></td>
                        <td class="align-middle"><small><?= date('d/m/Y H:i', strtotime($row['created_at'])) ?></small></td>
                        <td class="text-center align-middle">
                            <a href="order_detail.php?id=<?= $row['id'] ?>" class="btn btn-sm btn-info" title="Xem & Xuất hóa đơn"><i class="fas fa-file-invoice"></i> Chi tiết</a>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        <?php else: ?>
            <div class="text-center py-5">
                <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">Không tìm thấy đơn hàng nào phù hợp.</h5>
            </div>
        <?php endif; ?>
    </div>
</div>

<?php include 'includes/footer.php'; ?>