<?php
require_once '../api/db_connect.php';

// --- 1. XỬ LÝ HÀNH ĐỘNG (DUYỆT / TỪ CHỐI / KHÓA) ---
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = (int)$_GET['id'];
    $action = $_GET['action'];
    $status = '';
    $msg = '';

    if ($action == 'approve') {
        $status = 'approved';
        $msg = "Chúc mừng! Hồ sơ đối tác của bạn đã được duyệt. Bạn có thể bắt đầu nhận đơn ngay bây giờ.";
    } elseif ($action == 'reject') {
        $status = 'unverified'; // Trả về trạng thái chưa xác minh để họ nộp lại
        $msg = "Rất tiếc, hồ sơ đối tác của bạn không đạt yêu cầu. Vui lòng kiểm tra lại thông tin và ảnh hồ sơ.";
    }

    if ($status != '') {
        $conn->query("UPDATE driver_profiles SET status = '$status' WHERE id = $id");
        // Gửi thông báo cho tài xế
        $u_id_query = $conn->query("SELECT user_id FROM driver_profiles WHERE id = $id")->fetch_assoc();
        $user_id = $u_id_query['user_id'];
        $conn->query("INSERT INTO notifications (user_id, title, message) VALUES ($user_id, 'Trạng thái hồ sơ', '$msg')");
    }
    header("Location: drivers.php"); exit;
}

// --- 2. XỬ LÝ BỘ LỌC VÀ TÌM KIẾM ---
$search = isset($_GET['search']) ? $conn->real_escape_string($_GET['search']) : '';
$status_filter = isset($_GET['status']) ? $_GET['status'] : '';

$sql = "SELECT dp.*, u.name, u.email, u.phone, 
        (SELECT COUNT(*) FROM orders WHERE driver_id = u.id AND status = 'completed') as total_done,
        (SELECT balance FROM driver_wallets WHERE driver_id = u.id) as wallet_balance
        FROM driver_profiles dp 
        JOIN users u ON dp.user_id = u.id 
        WHERE 1=1";

if ($search != '') {
    $sql .= " AND (u.name LIKE '%$search%' OR dp.vehicle_plate LIKE '%$search%' OR u.phone LIKE '%$search%')";
}
if ($status_filter != '') {
    $sql .= " AND dp.status = '$status_filter'";
}

$sql .= " ORDER BY dp.id DESC";
$result = $conn->query($sql);

$page_title = "Quản lý Đối tác Tài xế";
include 'includes/sidebar.php'; 
?>

<!-- KHUNG BỘ LỌC -->
<div class="card shadow mb-4">
    <div class="card-body bg-light py-3">
        <form method="GET" action="drivers.php" class="form-row align-items-center">
            <div class="col-md-4 mb-2">
                <input type="text" name="search" class="form-control" placeholder="Tìm tên, SĐT, Biển số..." value="<?= htmlspecialchars($search) ?>">
            </div>
            <div class="col-md-3 mb-2">
                <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="pending" <?= $status_filter == 'pending' ? 'selected' : '' ?>>Đang chờ duyệt</option>
                    <option value="approved" <?= $status_filter == 'approved' ? 'selected' : '' ?>>Đã duyệt</option>
                    <option value="unverified" <?= $status_filter == 'unverified' ? 'selected' : '' ?>>Bị từ chối/Chưa nộp</option>
                </select>
            </div>
            <div class="col-md-2 mb-2">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Tìm kiếm</button>
            </div>
            <?php if($search != '' || $status_filter != ''): ?>
                <div class="col-md-2 mb-2">
                    <a href="drivers.php" class="btn btn-outline-danger w-100">Xóa lọc</a>
                </div>
            <?php endif; ?>
        </form>
    </div>
</div>

<!-- BẢNG DANH SÁCH -->
<div class="card shadow mb-4">
    <div class="card-body table-responsive">
        <table class="table table-bordered table-hover align-middle">
            <thead class="thead-dark text-center">
                <tr>
                    <th>STT</th>
                    <th>Ảnh chân dung</th>
                    <th>Thông tin Tài xế</th>
                    <th>Phương tiện</th>
                    <th>Hiệu suất / Ví</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <?php 
                $stt = 1;
                while($row = $result->fetch_assoc()): 
                    $status_class = ($row['status'] == 'approved') ? 'success' : (($row['status'] == 'pending') ? 'warning text-dark' : 'danger');
                ?>
                <tr>
                    <td class="text-center font-weight-bold"><?= $stt++ ?></td>
                    <td class="text-center">
                        <img src="<?= $row['portrait_image'] ? '../'.$row['portrait_image'] : 'https://ui-avatars.com/api/?name='.urlencode($row['name']) ?>" 
                             class="rounded-circle shadow-sm border" width="60" height="60" style="object-fit: cover;">
                    </td>
                    <td>
                        <a href="user_detail.php?id=<?= $row['user_id'] ?>" class="font-weight-bold text-primary"><?= $row['name'] ?></a><br>
                        <small class="text-muted"><i class="fas fa-phone fa-xs"></i> <?= $row['phone'] ?></small><br>
                        <small class="text-muted"><i class="fas fa-envelope fa-xs"></i> <?= $row['email'] ?></small>
                    </td>
                    <td>
                        <span class="badge badge-dark"><?= $row['vehicle_plate'] ?></span><br>
                        <small><?= $row['vehicle_type'] ?></small><br>
                        <a href="#" class="small text-info font-italic" data-toggle="modal" data-target="#licenseModal<?= $row['id'] ?>">Xem bằng lái</a>
                    </td>
                    <td class="text-center">
                        <div class="small">Đã giao: <strong><?= $row['total_done'] ?> đơn</strong></div>
                        <div class="text-success font-weight-bold"><?= number_format($row['wallet_balance'] ?? 0) ?>đ</div>
                    </td>
                    <td class="text-center">
                        <span class="badge badge-<?= $status_class ?> p-2 w-100">
                            <?= strtoupper($row['status'] == 'approved' ? 'Đã duyệt' : ($row['status'] == 'pending' ? 'Chờ duyệt' : 'Từ chối')) ?>
                        </span>
                    </td>
                    <td class="text-center">
                        <div class="d-flex justify-content-center flex-column">
                            <?php if($row['status'] == 'pending'): ?>
                                <a href="drivers.php?action=approve&id=<?= $row['id'] ?>" class="btn btn-sm btn-success mb-1" onclick="return confirm('Duyệt hồ sơ này?')">Duyệt</a>
                                <a href="drivers.php?action=reject&id=<?= $row['id'] ?>" class="btn btn-sm btn-outline-danger mb-1" onclick="return confirm('Từ chối hồ sơ này?')">Từ chối</a>
                            <?php endif; ?>
                            <a href="user_detail.php?id=<?= $row['user_id'] ?>" class="btn btn-sm btn-info">Chi tiết</a>
                        </div>
                    </td>
                </tr>

                <!-- MODAL XEM BẰNG LÁI -->
                <div class="modal fade" id="licenseModal<?= $row['id'] ?>" tabindex="-1" role="dialog">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-header bg-dark text-white">
                                <h5 class="modal-title">Bằng lái xe: <?= $row['name'] ?></h5>
                                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                            </div>
                            <div class="modal-body text-center bg-light">
                                <img src="../<?= $row['license_image'] ?>" class="img-fluid rounded shadow">
                            </div>
                        </div>
                    </div>
                </div>

                <?php endwhile; ?>
            </tbody>
        </table>
    </div>
</div>

<?php include 'includes/footer.php'; ?>