<?php
require_once '../api/db_connect.php';

if (!isset($_GET['id'])) { header("Location: users.php"); exit; }
$id = (int)$_GET['id'];

// 1. Lấy thông tin cơ bản
$user = $conn->query("SELECT * FROM users WHERE id = $id")->fetch_assoc();
if (!$user) { echo "Người dùng không tồn tại"; exit; }

$page_title = "Chi tiết: " . $user['name'];
include 'includes/sidebar.php';

// 2. Logic lấy dữ liệu theo vai trò
$role = $user['role'];
$driver_profile = null;
$wallet = null;
$addresses = [];
$orders = [];

if ($role == 'driver') {
    // Lấy hồ sơ tài xế và ví
    $driver_profile = $conn->query("SELECT * FROM driver_profiles WHERE user_id = $id")->fetch_assoc();
    $wallet = $conn->query("SELECT balance FROM driver_wallets WHERE driver_id = $id")->fetch_assoc();
    // Lấy 10 đơn hàng gần nhất tài xế đã nhận
    $orders = $conn->query("SELECT * FROM orders WHERE driver_id = $id ORDER BY created_at DESC LIMIT 10");
} else {
    // Lấy danh sách địa chỉ của khách hàng
    $addr_res = $conn->query("SELECT * FROM user_addresses WHERE user_id = $id");
    while($a = $addr_res->fetch_assoc()) { $addresses[] = $a; }
    // Lấy 10 đơn hàng gần nhất khách đã đặt
    $orders = $conn->query("SELECT * FROM orders WHERE customer_id = $id ORDER BY created_at DESC LIMIT 10");
}
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="h3 mb-0 text-gray-800">Hồ sơ người dùng #<?= $user['id'] ?></h3>
    <a href="users.php" class="btn btn-secondary btn-sm shadow-sm"><i class="fas fa-arrow-left"></i> Quay lại</a>
</div>

<div class="row">
    <!-- CỘT TRÁI: THÔNG TIN CÁ NHÂN -->
    <div class="col-xl-4 col-lg-5">
        <div class="card shadow mb-4">
            <div class="card-body text-center">
                <img src="<?= ($user['avatar'] != null) ? '../'.$user['avatar'] : 'https://ui-avatars.com/api/?name='.urlencode($user['name']).'&size=128' ?>" 
                     class="rounded-circle img-profile mb-3 shadow" width="150" height="150" style="object-fit: cover; border: 5px solid #fff;">
                <h4 class="font-weight-bold text-dark"><?= $user['name'] ?></h4>
                <p class="text-muted"><?= $user['email'] ?></p>
                <div class="mb-3">
                    <span class="badge badge-<?= $user['role'] == 'driver' ? 'warning' : 'info' ?> p-2 uppercase">
                        <?= strtoupper($user['role']) ?>
                    </span>
                    <?= $user['is_banned'] ? '<span class="badge badge-danger p-2 ml-2">ĐÃ KHÓA</span>' : '<span class="badge badge-success p-2 ml-2">HOẠT ĐỘNG</span>' ?>
                </div>
                <hr>
                <div class="text-left">
                    <p><strong><i class="fas fa-phone mr-2"></i> Điện thoại:</strong> <?= $user['phone'] ?? 'N/A' ?></p>
                    <p><strong><i class="fas fa-calendar-alt mr-2"></i> Ngày tham gia:</strong> <?= date('d/m/Y', strtotime($user['created_at'])) ?></p>
                </div>
                <?php if($user['role'] != 'admin'): ?>
                <a href="users.php?action=<?= $user['is_banned'] ? 'unban' : 'ban' ?>&id=<?= $user['id'] ?>" 
                   class="btn btn-<?= $user['is_banned'] ? 'success' : 'danger' ?> btn-block mt-3 shadow-sm">
                    <i class="fas fa-user-<?= $user['is_banned'] ? 'check' : 'slash' ?>"></i> 
                    <?= $user['is_banned'] ? 'Mở khóa tài khoản' : 'Khóa tài khoản này' ?>
                </a>
                <?php endif; ?>
            </div>
        </div>

        <!-- THÔNG TIN RIÊNG CHO TÀI XẾ (XE & VÍ) -->
        <?php if($role == 'driver' && $driver_profile): ?>
        <div class="card shadow mb-4 border-left-warning">
            <div class="card-header py-3 bg-white">
                <h6 class="m-0 font-weight-bold text-warning"><i class="fas fa-motorcycle"></i> Thông tin đối tác</h6>
            </div>
            <div class="card-body">
                <p><strong>Biển số:</strong> <span class="badge badge-dark"><?= $driver_profile['vehicle_plate'] ?></span></p>
                <p><strong>Loại xe:</strong> <?= $driver_profile['vehicle_type'] ?></p>
                <p><strong>Số dư ví:</strong> <span class="text-success font-weight-bold"><?= number_format($wallet['balance'] ?? 0) ?>đ</span></p>
                <p><strong>Trạng thái hồ sơ:</strong> 
                    <span class="badge badge-<?= $driver_profile['status'] == 'approved' ? 'success' : 'warning' ?>">
                        <?= strtoupper($driver_profile['status']) ?>
                    </span>
                </p>
                <label class="small font-weight-bold">Ảnh bằng lái:</label>
                <img src="../<?= $driver_profile['license_image'] ?>" class="img-fluid rounded border cursor-pointer" 
                     onclick="window.open(this.src)" title="Bấm để xem ảnh lớn">
            </div>
        </div>
        <?php endif; ?>
    </div>

    <!-- CỘT PHẢI: HOẠT ĐỘNG (ĐỊA CHỈ & ĐƠN HÀNG) -->
    <div class="col-xl-8 col-lg-7">
        
        <!-- Tab Danh sách địa chỉ (Chỉ dành cho Khách) -->
        <?php if($role == 'customer'): ?>
        <div class="card shadow mb-4">
            <div class="card-header py-3 bg-white">
                <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-map-marker-alt"></i> Sổ địa chỉ đã lưu</h6>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm mb-0">
                    <thead class="bg-light"><tr><th>Tên gợi nhớ</th><th>Địa chỉ chi tiết</th></tr></thead>
                    <tbody>
                        <?php foreach($addresses as $addr): ?>
                        <tr>
                            <td class="pl-3"><strong><?= $addr['title'] ?></strong></td>
                            <td><?= $addr['address_detail'] ?></td>
                        </tr>
                        <?php endforeach; if(empty($addresses)) echo "<tr><td colspan='2' class='text-center p-3 text-muted'>Chưa có địa chỉ nào</td></tr>"; ?>
                    </tbody>
                </table>
            </div>
        </div>
        <?php endif; ?>

        <!-- Lịch sử đơn hàng gần đây (Chung) -->
        <div class="card shadow mb-4">
            <div class="card-header py-3 bg-white d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-history"></i> 10 Đơn hàng gần nhất</h6>
                <a href="orders.php" class="small">Xem tất cả</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Ngày đặt</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while($o = $orders->fetch_assoc()): ?>
                            <tr>
                                <td><a href="order_detail.php?id=<?= $o['id'] ?>" class="font-weight-bold">#EPC-<?= $o['id'] ?></a></td>
                                <td><?= date('d/m/Y H:i', strtotime($o['created_at'])) ?></td>
                                <td class="text-danger font-weight-bold"><?= number_format($o['final_amount']) ?>đ</td>
                                <td>
                                    <?php
                                        $s = $o['status'];
                                        $c = ($s == 'completed') ? 'success' : (($s == 'cancelled') ? 'danger' : 'warning text-dark');
                                        echo "<span class='badge badge-$c px-2 py-1'>".strtoupper($s)."</span>";
                                    ?>
                                </td>
                            </tr>
                            <?php endwhile; if($orders->num_rows == 0) echo "<tr><td colspan='4' class='text-center p-4 text-muted'>Chưa có hoạt động nào</td></tr>"; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>