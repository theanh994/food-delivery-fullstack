<?php
require_once '../api/db_connect.php';

// Lấy danh sách yêu cầu rút tiền JOIN với bảng users và driver_wallets
$sql = "SELECT w.*, u.name as driver_name, u.phone, dw.balance 
        FROM withdrawal_requests w 
        JOIN users u ON w.driver_id = u.id 
        JOIN driver_wallets dw ON w.driver_id = dw.driver_id 
        ORDER BY w.created_at DESC";
$result = $conn->query($sql);

$page_title = "Quản lý Rút tiền";
include 'includes/sidebar.php'; 
?>

<div class="card shadow mb-4">
    <div class="card-header py-3 bg-white">
        <h6 class="m-0 font-weight-bold text-primary">Danh sách yêu cầu rút tiền của Tài xế</h6>
    </div>
    <div class="card-body table-responsive">
        <?php if($result->num_rows > 0): ?>
            <table class="table table-bordered table-hover align-middle">
                <thead class="thead-light">
                    <tr>
                        <th class="text-center">STT</th>
                        <th>Tài xế</th>
                        <th>Số dư hiện tại</th>
                        <th>Số tiền yêu cầu</th>
                        <th>Ngày yêu cầu</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $stt = 1;
                    while($row = $result->fetch_assoc()): 
                        $status = $row['status'];
                        $badge = ($status == 'pending') ? 'warning text-dark' : (($status == 'approved') ? 'success' : 'danger');
                    ?>
                    <tr>
                        <td class="text-center font-weight-bold"><?= $stt++ ?></td>
                        <td>
                            <strong><?= $row['driver_name'] ?></strong><br>
                            <small class="text-muted"><?= $row['phone'] ?></small>
                        </td>
                        <td class="text-success font-weight-bold"><?= number_format($row['balance']) ?>đ</td>
                        <td class="text-danger font-weight-bold"><?= number_format($row['amount']) ?>đ</td>
                        <td><small><?= date('d/m/Y H:i', strtotime($row['created_at'])) ?></small></td>
                        <td class="text-center">
                            <span class="badge badge-<?= $badge ?> p-2"><?= strtoupper($status) ?></span>
                        </td>
                        <td class="text-center">
                            <?php if($status == 'pending'): ?>
                                <div class="d-flex justify-content-center">
                                    <a href="approve_withdrawal.php?id=<?= $row['id'] ?>&action=approve" class="btn btn-sm btn-success mr-2" onclick="return confirm('Xác nhận đã chuyển khoản cho tài xế?')">Duyệt</a>
                                    <a href="approve_withdrawal.php?id=<?= $row['id'] ?>&action=reject" class="btn btn-sm btn-outline-danger">Từ chối</a>
                                </div>
                            <?php else: ?>
                                <span class="text-muted small">Đã xử lý</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        <?php else: ?>
            <div class="text-center py-5">
                <i class="fas fa-wallet fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">Chưa có yêu cầu rút tiền nào.</h5>
            </div>
        <?php endif; ?>
    </div>
</div>

<?php include 'includes/footer.php'; ?>