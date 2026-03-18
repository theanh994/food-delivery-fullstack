<?php
require_once '../api/db_connect.php';

if (!isset($_GET['food_id'])) { header("Location: foods.php"); exit; }
$food_id = (int)$_GET['food_id'];

// --- XỬ LÝ THÊM/XÓA ---
if (isset($_POST['add_group'])) {
    $name = $conn->real_escape_string($_POST['group_name']);
    $is_req = isset($_POST['is_required']) ? 1 : 0;
    $is_multi = isset($_POST['is_multi']) ? 1 : 0;
    $conn->query("INSERT INTO option_groups (food_id, name, is_required, is_multi_select) VALUES ($food_id, '$name', $is_req, $is_multi)");
    header("Location: food_options.php?food_id=$food_id"); exit;
}
if (isset($_POST['add_item'])) {
    $g_id = (int)$_POST['group_id'];
    $name = $conn->real_escape_string($_POST['item_name']);
    $price = (float)$_POST['extra_price'];
    $conn->query("INSERT INTO option_items (group_id, name, extra_price) VALUES ($g_id, '$name', $price)");
    header("Location: food_options.php?food_id=$food_id"); exit;
}
if (isset($_GET['del_group'])) {
    $g_id = (int)$_GET['del_group'];
    $conn->query("DELETE FROM option_groups WHERE id = $g_id");
    header("Location: food_options.php?food_id=$food_id"); exit;
}
if (isset($_GET['del_item'])) {
    $i_id = (int)$_GET['del_item'];
    $conn->query("DELETE FROM option_items WHERE id = $i_id");
    header("Location: food_options.php?food_id=$food_id"); exit;
}

$food = $conn->query("SELECT name FROM foods WHERE id = $food_id")->fetch_assoc();
$groups = $conn->query("SELECT * FROM option_groups WHERE food_id = $food_id");

$page_title = "Cấu hình Tùy chọn";
include 'includes/sidebar.php'; 
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="text-gray-800">Món: <strong class="text-primary"><?= $food['name'] ?></strong></h4>
    <a href="foods.php" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Quay lại Thực đơn</a>
</div>

<div class="row">
    <!-- CỘT THÊM NHÓM -->
    <div class="col-lg-4 mb-4">
        <div class="card shadow border-left-primary">
            <div class="card-header bg-white font-weight-bold text-primary">
                <i class="fas fa-layer-group"></i> Thêm Nhóm Tùy Chọn
            </div>
            <div class="card-body">
                <form method="POST">
                    <div class="form-group">
                        <label>Tên nhóm (VD: Kích cỡ, Đá, Đường)</label>
                        <input type="text" name="group_name" class="form-control" required>
                    </div>
                    <div class="custom-control custom-checkbox mb-2">
                        <input type="checkbox" class="custom-control-input" id="checkReq" name="is_required">
                        <label class="custom-control-label" for="checkReq">Bắt buộc khách phải chọn <span class="text-danger">*</span></label>
                    </div>
                    <div class="custom-control custom-checkbox mb-4">
                        <input type="checkbox" class="custom-control-input" id="checkMulti" name="is_multi">
                        <label class="custom-control-label" for="checkMulti">Cho phép chọn nhiều (Như Topping)</label>
                    </div>
                    <button type="submit" name="add_group" class="btn btn-primary w-100"><i class="fas fa-plus"></i> Tạo Nhóm Mới</button>
                </form>
            </div>
        </div>
    </div>

    <!-- CỘT DANH SÁCH NHÓM & ITEM -->
    <div class="col-lg-8">
        <?php if($groups->num_rows == 0): ?>
            <div class="alert alert-info">Món ăn này chưa có tùy chọn nào. Hãy tạo nhóm tùy chọn đầu tiên!</div>
        <?php endif; ?>

        <div class="row">
            <?php while($g = $groups->fetch_assoc()): ?>
            <div class="col-md-12 mb-4">
                <div class="card shadow">
                    <!-- Tiêu đề nhóm -->
                    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center py-2">
                        <div>
                            <span class="font-weight-bold h6 mb-0"><?= $g['name'] ?></span>
                            <?= $g['is_required'] ? '<span class="badge badge-danger ml-2">Bắt buộc</span>' : '' ?>
                            <?= $g['is_multi_select'] ? '<span class="badge badge-info ml-1">Chọn nhiều</span>' : '<span class="badge badge-secondary ml-1">Chọn 1</span>' ?>
                        </div>
                        <a href="food_options.php?food_id=<?= $food_id ?>&del_group=<?= $g['id'] ?>" class="btn btn-sm btn-outline-light" onclick="return confirm('Xóa nhóm này sẽ xóa tất cả lựa chọn con bên trong. Bạn chắc chứ?');"><i class="fas fa-trash"></i> Xóa nhóm</a>
                    </div>
                    
                    <div class="card-body p-0">
                        <!-- Danh sách Item con -->
                        <table class="table table-sm table-borderless mb-0">
                            <tbody>
                                <?php 
                                $items = $conn->query("SELECT * FROM option_items WHERE group_id = " . $g['id']);
                                if($items->num_rows > 0):
                                    while($item = $items->fetch_assoc()): 
                                ?>
                                <tr class="border-bottom">
                                    <td class="pl-4 align-middle"><i class="fas fa-chevron-right text-gray-300 mr-2"></i> <strong><?= $item['name'] ?></strong></td>
                                    <td class="align-middle text-success font-weight-bold">+<?= number_format($item['extra_price']) ?>đ</td>
                                    <td class="text-right pr-4 align-middle">
                                        <a href="food_options.php?food_id=<?= $food_id ?>&del_item=<?= $item['id'] ?>" class="text-danger" title="Xóa tùy chọn này"><i class="fas fa-times-circle"></i></a>
                                    </td>
                                </tr>
                                <?php endwhile; else: ?>
                                <tr><td colspan="3" class="text-center text-muted py-3">Nhóm này chưa có lựa chọn nào.</td></tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Form thêm item nhanh -->
                    <div class="card-footer bg-light">
                        <form method="POST" class="d-flex align-items-center">
                            <input type="hidden" name="group_id" value="<?= $g['id'] ?>">
                            <input type="text" name="item_name" class="form-control form-control-sm mr-2" placeholder="Nhập tên lựa chọn (VD: Size L)" required>
                            <input type="number" name="extra_price" class="form-control form-control-sm mr-2" placeholder="Giá cộng thêm (0 nếu miễn phí)" required style="max-width: 250px;">
                            <button type="submit" name="add_item" class="btn btn-success btn-sm text-nowrap"><i class="fas fa-plus"></i> Thêm Lựa chọn</button>
                        </form>
                    </div>
                </div>
            </div>
            <?php endwhile; ?>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>