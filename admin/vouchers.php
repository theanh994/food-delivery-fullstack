<?php
require_once '../api/db_connect.php';

// --- 1. XỬ LÝ THÊM VOUCHER MỚI ---
if (isset($_POST['add_voucher'])) {
    $code = strtoupper($conn->real_escape_string($_POST['code']));
    $discount = (float)$_POST['discount_amount'];
    $min_spend = (float)$_POST['min_spend'];
    $expiry = $_POST['expiry_date'];
    $limit = (int)$_POST['usage_limit'];

    $sql = "INSERT INTO vouchers (code, discount_amount, min_spend, expiry_date, usage_limit, status) 
            VALUES ('$code', $discount, $min_spend, '$expiry', $limit, 'active')";
    
    if ($conn->query($sql)) {
        header("Location: vouchers.php?msg=added"); exit;
    }
}

// --- 2. XỬ LÝ XÓA VOUCHER ---
if (isset($_GET['delete_id'])) {
    $id = (int)$_GET['delete_id'];
    $conn->query("DELETE FROM vouchers WHERE id = $id");
    header("Location: vouchers.php"); exit;
}

// --- 3. XỬ LÝ BẬT/TẮT TRẠNG THÁI ---
if (isset($_GET['toggle_id'])) {
    $id = (int)$_GET['toggle_id'];
    $conn->query("UPDATE vouchers SET status = IF(status='active', 'inactive', 'active') WHERE id = $id");
    header("Location: vouchers.php"); exit;
}

// --- 4. LẤY DANH SÁCH ---
$vouchers = $conn->query("SELECT * FROM vouchers ORDER BY created_at DESC");

$page_title = "Quản lý Voucher & Khuyến mãi";
include 'includes/sidebar.php';
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="text-primary font-weight-bold">Danh sách Mã giảm giá</h4>
    <button class="btn btn-primary shadow-sm" data-toggle="modal" data-target="#addVoucherModal">
        <i class="fas fa-plus"></i> Tạo Voucher Mới
    </button>
</div>

<div class="card shadow mb-4">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle">
                <thead class="thead-light">
                    <tr class="text-center">
                        <th>STT</th>
                        <th>Mã Code</th>
                        <th>Mức giảm</th>
                        <th>Đơn tối thiểu</th>
                        <th>Hạn dùng</th>
                        <th>Đã dùng / Giới hạn</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $stt = 1;
                    while($v = $vouchers->fetch_assoc()): 
                        $is_expired = strtotime($v['expiry_date']) < time();
                    ?>
                    <tr class="<?= $is_expired ? 'table-secondary' : '' ?>">
                        <td class="text-center font-weight-bold"><?= $stt++ ?></td>
                        <td class="text-center">
                            <span class="badge badge-dark p-2" style="font-size: 14px; letter-spacing: 1px;">
                                <?= $v['code'] ?>
                            </span>
                        </td>
                        <td class="text-right text-success font-weight-bold"><?= number_format($v['discount_amount']) ?>đ</td>
                        <td class="text-right"><?= number_format($v['min_spend']) ?>đ</td>
                        <td class="text-center">
                            <small class="<?= $is_expired ? 'text-danger font-weight-bold' : '' ?>">
                                <?= date('d/m/Y', strtotime($v['expiry_date'])) ?>
                                <?= $is_expired ? '<br>(Hết hạn)' : '' ?>
                            </small>
                        </td>
                        <td class="text-center">
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-info" style="width: <?= ($v['used_count']/$v['usage_limit'])*100 ?>%"></div>
                            </div>
                            <small><?= $v['used_count'] ?> / <?= $v['usage_limit'] ?></small>
                        </td>
                        <td class="text-center">
                            <?php if($v['status'] == 'active' && !$is_expired): ?>
                                <span class="badge badge-success p-2">Đang chạy</span>
                            <?php else: ?>
                                <span class="badge badge-danger p-2">Tạm ngưng</span>
                            <?php endif; ?>
                        </td>
                        <td class="text-center">
                            <div class="d-flex justify-content-center">
                                <a href="vouchers.php?toggle_id=<?= $v['id'] ?>" class="btn btn-sm <?= $v['status'] == 'active' ? 'btn-warning' : 'btn-success' ?> mr-2" title="Bật/Tắt">
                                    <i class="fas <?= $v['status'] == 'active' ? 'fa-pause' : 'fa-play' ?>"></i>
                                </a>
                                <a href="vouchers.php?delete_id=<?= $v['id'] ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Xác nhận xóa mã này?')" title="Xóa">
                                    <i class="fas fa-trash"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- MODAL THÊM MỚI -->
<div class="modal fade" id="addVoucherModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title font-weight-bold">TẠO MÃ GIẢM GIÁ MỚI</h5>
                <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <div class="form-group">
                        <label class="font-weight-bold">Mã Voucher (Không dấu, không cách)</label>
                        <input type="text" name="code" class="form-control form-control-lg text-uppercase" placeholder="VD: GIAM50K" required>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Số tiền giảm (đ)</label>
                            <input type="number" name="discount_amount" class="form-control" placeholder="50000" required>
                        </div>
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Đơn tối thiểu (đ)</label>
                            <input type="number" name="min_spend" class="form-control" value="0" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Ngày hết hạn</label>
                            <input type="date" name="expiry_date" class="form-control" required>
                        </div>
                        <div class="form-group col-md-6">
                            <label class="font-weight-bold">Lượt sử dụng tối đa</label>
                            <input type="number" name="usage_limit" class="form-control" value="100" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" name="add_voucher" class="btn btn-primary px-4 font-weight-bold">PHÁT HÀNH MÃ</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>