<?php
require_once '../api/db_connect.php';

// --- 1. XỬ LÝ KHÓA/MỞ KHÓA TÀI KHOẢN ---
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = (int)$_GET['id'];
    $action = $_GET['action'];
    $is_banned = ($action == 'ban') ? 1 : 0;
    
    // Không cho phép khóa Admin để tránh lỗi hệ thống
    $conn->query("UPDATE users SET is_banned = $is_banned WHERE id = $id AND role != 'admin'");
    header("Location: " . $_SERVER['HTTP_REFERER']); exit;
}

// --- 2. XỬ LÝ BỘ LỌC VÀ SẮP XẾP ---
$role_filter = isset($_GET['role']) ? $conn->real_escape_string($_GET['role']) : '';
$sort_id = isset($_GET['sort_id']) ? $_GET['sort_id'] : 'desc'; // Mặc định ID lớn nhất lên đầu

$sql = "SELECT * FROM users WHERE 1=1";

// Lọc theo vai trò
if ($role_filter != '') {
    $sql .= " AND role = '$role_filter'";
}

// Sắp xếp theo ID
if ($sort_id == 'asc') {
    $sql .= " ORDER BY id ASC";
} else {
    $sql .= " ORDER BY id DESC";
}

$result = $conn->query($sql);

$page_title = "Quản lý Người dùng";
include 'includes/sidebar.php'; 
?>

<!-- KHUNG BỘ LỌC NÂNG CẤP -->
<div class="card shadow mb-4">
    <div class="card-body bg-light py-3">
        <form method="GET" action="users.php" class="form-row align-items-center">
            
            <!-- Lọc vai trò -->
            <div class="col-md-3 mb-2">
                <label class="small font-weight-bold text-muted mb-1">Vai trò người dùng</label>
                <select name="role" class="form-control">
                    <option value="">-- Tất cả vai trò --</option>
                    <option value="customer" <?= $role_filter == 'customer' ? 'selected' : '' ?>>Khách hàng</option>
                    <option value="driver" <?= $role_filter == 'driver' ? 'selected' : '' ?>>Tài xế</option>
                    <option value="admin" <?= $role_filter == 'admin' ? 'selected' : '' ?>>Quản trị viên</option>
                </select>
            </div>

            <!-- Sắp xếp ID -->
            <div class="col-md-3 mb-2">
                <label class="small font-weight-bold text-muted mb-1">Thứ tự ID</label>
                <select name="sort_id" class="form-control">
                    <option value="desc" <?= $sort_id == 'desc' ? 'selected' : '' ?>>ID: Mới nhất (Giảm dần)</option>
                    <option value="asc" <?= $sort_id == 'asc' ? 'selected' : '' ?>>ID: Cũ nhất (Tăng dần)</option>
                </select>
            </div>

            <div class="col-md-2 mb-2 mt-4">
                <button type="submit" class="btn btn-primary w-100"><i class="fas fa-filter"></i> Áp dụng</button>
            </div>

            <?php if($role_filter != '' || $sort_id != 'desc'): ?>
            <div class="col-md-2 mb-2 mt-4">
                <a href="users.php" class="btn btn-outline-danger w-100"><i class="fas fa-times"></i> Xóa lọc</a>
            </div>
            <?php endif; ?>
        </form>
    </div>
</div>

<!-- BẢNG DÂN DANH SÁCH -->
<div class="card shadow mb-4">
    <div class="card-body table-responsive">
        <?php if($result->num_rows > 0): ?>
            <table class="table table-bordered table-hover align-middle">
                <thead class="thead-light">
                    <tr>
                        <th width="5%" class="text-center">STT</th>
                        <th width="8%" class="text-center">ID</th>
                        <th width="22%">Họ và tên</th>
                        <th width="25%">Thông tin liên lạc</th>
                        <th width="15%" class="text-center">Vai trò</th>
                        <th width="10%" class="text-center">Trạng thái</th>
                        <th width="15%" class="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $stt = 1;
                    while($row = $result->fetch_assoc()): 
                        // Style cho Role Badge
                        $role_badge = 'info';
                        if($row['role'] == 'driver') $role_badge = 'warning text-dark';
                        elseif($row['role'] == 'admin') $role_badge = 'danger';
                    ?>
                    <tr>
                        <td class="text-center align-middle font-weight-bold"><?= $stt++ ?></td>
                        <td class="text-center align-middle text-muted">#<?= $row['id'] ?></td>
                        <td class="align-middle">
                            <div class="d-flex align-items-center">
                                <div class="mr-3">
                                    <img src="<?= ($row['avatar'] != null) ? '../'.$row['avatar'] : 'https://ui-avatars.com/api/?name='.urlencode($row['name']).'&background=random' ?>" class="rounded-circle shadow-sm" width="40" height="40" style="object-fit: cover;">
                                </div>
                                <div>
                                    <div class="font-weight-bold text-dark"><?= $row['name'] ?></div>
                                    <small class="text-muted">Tham gia: <?= date('d/m/Y', strtotime($row['created_at'])) ?></small>
                                </div>
                            </div>
                        </td>
                        <td class="align-middle">
                            <i class="fas fa-envelope fa-xs text-muted mr-1"></i> <?= $row['email'] ?><br>
                            <i class="fas fa-phone fa-xs text-muted mr-1"></i> <?= $row['phone'] ?? 'Chưa cập nhật' ?>
                        </td>
                        <td class="text-center align-middle">
                            <span class="badge badge-<?= $role_badge ?> p-2" style="min-width: 90px;">
                                <?= strtoupper($row['role']) ?>
                            </span>
                        </td>
                        <td class="text-center align-middle">
                            <?= $row['is_banned'] 
                                ? '<span class="badge badge-danger p-2"><i class="fas fa-lock"></i> Khóa</span>' 
                                : '<span class="badge badge-success p-2"><i class="fas fa-check"></i> OK</span>' ?>
                        </td>
                        <td class="text-center align-middle">
                            <?php if($row['role'] != 'admin'): ?>
                                <div class="d-flex justify-content-center">
                                    <?php if($row['is_banned']): ?>
                                        <a href="users.php?action=unban&id=<?= $row['id'] ?>" class="btn btn-sm btn-success shadow-sm" title="Mở khóa tài khoản">
                                            <i class="fas fa-unlock"></i> Mở khóa
                                        </a>
                                    <?php else: ?>
                                        <a href="users.php?action=ban&id=<?= $row['id'] ?>" class="btn btn-sm btn-outline-danger shadow-sm" onclick="return confirm('Khóa tài khoản này: User sẽ không thể đăng nhập?');" title="Khóa tài khoản">
                                            <i class="fas fa-user-slash"></i> Khóa TK
                                        </a>
                                        <a href="user_detail.php?id=<?= $row['id'] ?>" class="btn btn-sm btn-info shadow-sm mr-1">
                                            <i class="fas fa-eye"></i> Chi tiết
                                        </a>
                                    <?php endif; ?>
                                </div>
                            <?php else: ?>
                                <span class="text-muted small">Mặc định</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        <?php else: ?>
            <div class="text-center py-5">
                <i class="fas fa-users-slash fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">Không tìm thấy người dùng nào.</h5>
            </div>
        <?php endif; ?>
    </div>
</div>

<?php include 'includes/footer.php'; ?>