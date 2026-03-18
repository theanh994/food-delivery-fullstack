<?php
require_once '../api/db_connect.php';

// --- 1. XỬ LÝ CÁC HÀNH ĐỘNG (THÊM, XÓA, ĐỔI TRẠNG THÁI) ---
if (isset($_POST['add_food'])) {
    $name = $conn->real_escape_string($_POST['name']);
    $cat_id = (int)$_POST['category_id'];
    $price = (float)$_POST['price'];
    $desc = $conn->real_escape_string($_POST['description']);
    $food_type = $conn->real_escape_string($_POST['food_type']); // Lấy thêm phân loại đồ ăn/thức uống
    
    $image_url = "";
    if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
        $target_dir = "../uploads/foods/";
        if (!file_exists($target_dir)) mkdir($target_dir, 0777, true);
        $file_name = time() . "_" . basename($_FILES["image"]["name"]);
        if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_dir . $file_name)) {
            $image_url = "uploads/foods/" . $file_name; 
        }
    }

    $sql = "INSERT INTO foods (category_id, food_type, name, description, price, image_url, is_available) 
            VALUES ($cat_id, '$food_type', '$name', '$desc', $price, '$image_url', 1)";
    $conn->query($sql);
    header("Location: foods.php"); exit;
}

if (isset($_GET['delete_id'])) {
    $del_id = (int)$_GET['delete_id'];
    $conn->query("DELETE FROM foods WHERE id = $del_id");
    header("Location: foods.php"); exit;
}

if (isset($_GET['toggle_id'])) {
    $t_id = (int)$_GET['toggle_id'];
    $conn->query("UPDATE foods SET is_available = NOT is_available WHERE id = $t_id");
    // Quay lại đúng URL hiện tại để giữ nguyên bộ lọc
    header("Location: " . $_SERVER['HTTP_REFERER']); exit; 
}

// --- 2. XỬ LÝ BỘ LỌC VÀ TÌM KIẾM (DYNAMIC SQL) ---

// Lấy các tham số từ URL (nếu có)
$search = isset($_GET['search']) ? $conn->real_escape_string($_GET['search']) : '';
$category_filter = isset($_GET['category']) ? $_GET['category'] : '';
$status_filter = isset($_GET['status']) ? $_GET['status'] : '';
$sort = isset($_GET['sort']) ? $_GET['sort'] : 'newest';

// Khởi tạo câu truy vấn cơ bản (1=1 để dễ dàng nối chuỗi AND phía sau)
$sql = "SELECT f.*, c.name as category_name 
        FROM foods f 
        LEFT JOIN categories c ON f.category_id = c.id 
        WHERE 1=1 ";

// Nối chuỗi Tìm kiếm theo tên
if ($search != '') {
    $sql .= " AND f.name LIKE '%$search%' ";
}

// Nối chuỗi Lọc theo danh mục
if ($category_filter != '') {
    $sql .= " AND f.category_id = " . (int)$category_filter;
}

// Nối chuỗi Lọc theo trạng thái (1 = Còn hàng, 0 = Hết hàng)
if ($status_filter != '') {
    $sql .= " AND f.is_available = " . (int)$status_filter;
}

// Nối chuỗi Sắp xếp (ORDER BY)
switch ($sort) {
    case 'price_asc': $sql .= " ORDER BY f.price ASC"; break;
    case 'price_desc': $sql .= " ORDER BY f.price DESC"; break;
    case 'name_asc': $sql .= " ORDER BY f.name ASC"; break;
    case 'name_desc': $sql .= " ORDER BY f.name DESC"; break;
    default: $sql .= " ORDER BY f.id DESC"; break; // Mặc định: Mới nhất
}

$foods = $conn->query($sql);

// Lấy danh mục để đổ vào Dropdown
$categories = $conn->query("SELECT * FROM categories WHERE status = 'active'");

// --- 3. HIỂN THỊ GIAO DIỆN ---
$page_title = "Quản lý Thực đơn";
include 'includes/sidebar.php'; 
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="text-primary font-weight-bold">Danh sách Món ăn</h4>
    <button class="btn btn-success shadow-sm" data-toggle="modal" data-target="#addFoodModal">
        <i class="fas fa-plus"></i> Thêm món mới
    </button>
</div>

<!-- KHUNG BỘ LỌC VÀ TÌM KIẾM -->
<div class="card shadow mb-4">
    <div class="card-body bg-light">
        <form method="GET" action="foods.php">
            <div class="row">
                <!-- Tìm kiếm theo tên -->
                <div class="col-md-3 mb-2">
                    <input type="text" name="search" class="form-control" placeholder="Tìm tên món ăn..." value="<?= htmlspecialchars($search) ?>">
                </div>
                
                <!-- Lọc theo danh mục -->
                <div class="col-md-2 mb-2">
                    <select name="category" class="form-control">
                        <option value="">-- Tất cả danh mục --</option>
                        <?php 
                        // Cần query lại list categories vì biến $categories đã bị dùng ở trên nếu đẩy vào Modal
                        $cat_filters = $conn->query("SELECT * FROM categories");
                        while($cat = $cat_filters->fetch_assoc()): 
                        ?>
                            <option value="<?= $cat['id'] ?>" <?= $category_filter == $cat['id'] ? 'selected' : '' ?>>
                                <?= $cat['name'] ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>
                
                <!-- Lọc theo trạng thái -->
                <div class="col-md-2 mb-2">
                    <select name="status" class="form-control">
                        <option value="">-- Trạng thái --</option>
                        <option value="1" <?= $status_filter === '1' ? 'selected' : '' ?>>Còn hàng</option>
                        <option value="0" <?= $status_filter === '0' ? 'selected' : '' ?>>Hết hàng</option>
                    </select>
                </div>

                <!-- Sắp xếp -->
                <div class="col-md-3 mb-2">
                    <select name="sort" class="form-control">
                        <option value="newest" <?= $sort == 'newest' ? 'selected' : '' ?>>Mới thêm gần đây</option>
                        <option value="price_asc" <?= $sort == 'price_asc' ? 'selected' : '' ?>>Giá: Thấp đến Cao</option>
                        <option value="price_desc" <?= $sort == 'price_desc' ? 'selected' : '' ?>>Giá: Cao đến Thấp</option>
                        <option value="name_asc" <?= $sort == 'name_asc' ? 'selected' : '' ?>>Tên: A - Z</option>
                        <option value="name_desc" <?= $sort == 'name_desc' ? 'selected' : '' ?>>Tên: Z - A</option>
                    </select>
                </div>

                <!-- Nút Lọc -->
                <div class="col-md-2 mb-2">
                    <button type="submit" class="btn btn-primary w-100"><i class="fas fa-filter"></i> Lọc</button>
                </div>
            </div>
            <!-- Link xóa bộ lọc -->
            <?php if($search != '' || $category_filter != '' || $status_filter != '' || $sort != 'newest'): ?>
                <div class="text-right mt-2">
                    <a href="foods.php" class="text-danger"><i class="fas fa-times"></i> Xóa bộ lọc</a>
                </div>
            <?php endif; ?>
        </form>
    </div>
</div>

<!-- BẢNG DỮ LIỆU -->
<div class="card shadow mb-4">
    <div class="card-body">
        <?php if($foods->num_rows > 0): ?>
            <table class="table table-bordered table-hover align-middle">
                <thead class="thead-light">
                    <tr>
                        <th width="5%">STT</th>
                        <th width="10%">Hình ảnh</th>
                        <th width="25%">Tên món ăn</th>
                        <th width="15%">Danh mục</th>
                        <th width="15%">Giá bán</th>
                        <th width="15%">Trạng thái</th>
                        <th width="15%" class="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $stt = 1; // Khởi tạo biến đếm
                    while($row = $foods->fetch_assoc()): 
                    ?>
                    <tr>
                        <td class="font-weight-bold text-center align-middle"><?= $stt++ ?></td>
                        <td class="align-middle">
                            <?php if($row['image_url']): ?>
                                <img src="<?= strpos($row['image_url'], 'http') === 0 ? $row['image_url'] : '../'.$row['image_url'] ?>" width="60" height="60" class="rounded shadow-sm" style="object-fit: cover;">
                            <?php else: ?>
                                <span class="text-muted">No Image</span>
                            <?php endif; ?>
                        </td>
                        <td class="align-middle">
                            <strong><?= $row['name'] ?></strong><br>
                            <small class="text-muted"><?= $row['food_type'] == 'drink' ? '(Đồ uống)' : '(Đồ ăn)' ?></small>
                        </td>
                        <td class="align-middle"><span class="badge badge-secondary p-2"><?= $row['category_name'] ?? 'Không rõ' ?></span></td>
                        <td class="align-middle text-danger font-weight-bold text-lg"><?= number_format($row['price']) ?>đ</td>
                        <td class="align-middle">
                            <?php if($row['is_available']): ?>
                                <a href="foods.php?toggle_id=<?= $row['id'] ?>" class="badge badge-success p-2 text-decoration-none">Còn hàng</a>
                            <?php else: ?>
                                <a href="foods.php?toggle_id=<?= $row['id'] ?>" class="badge badge-danger p-2 text-decoration-none">Hết hàng</a>
                            <?php endif; ?>
                        </td>
                        <td class="align-middle text-center">
                            <!-- CÁC NÚT ĐÃ ĐƯỢC XẾP NẰM NGANG BẰNG D-FLEX -->
                            <div class="d-flex justify-content-center">
                                <a href="food_options.php?food_id=<?= $row['id'] ?>" class="btn btn-sm btn-info mr-2" title="Cấu hình tùy chọn (Size/Topping)">
                                    <i class="fas fa-cogs"></i> Tùy chọn
                                </a>
                                <a href="foods.php?delete_id=<?= $row['id'] ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Xóa món này sẽ xóa luôn các đánh giá và tùy chọn liên quan. Xác nhận?');" title="Xóa món ăn">
                                    <i class="fas fa-trash"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        <?php else: ?>
            <div class="text-center py-4">
                <h5 class="text-muted">Không tìm thấy món ăn nào phù hợp với bộ lọc.</h5>
            </div>
        <?php endif; ?>
    </div>
</div>

<!-- MODAL: THÊM MÓN ĂN MỚI -->
<div class="modal fade" id="addFoodModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title">Thêm món ăn mới</h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Tên món ăn <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-6">
                            <label>Danh mục <span class="text-danger">*</span></label>
                            <select name="category_id" class="form-control" required>
                                <?php while($cat = $categories->fetch_assoc()): ?>
                                    <option value="<?= $cat['id'] ?>"><?= $cat['name'] ?></option>
                                <?php endwhile; ?>
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <label>Phân loại <span class="text-danger">*</span></label>
                            <select name="food_type" class="form-control" required>
                                <option value="food">Đồ ăn</option>
                                <option value="drink">Thức uống</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Giá bán (VND) <span class="text-danger">*</span></label>
                        <input type="number" name="price" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Hình ảnh món ăn</label>
                        <input type="file" name="image" class="form-control-file" accept="image/*">
                    </div>
                    <div class="form-group">
                        <label>Mô tả ngắn</label>
                        <textarea name="description" class="form-control" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                    <button type="submit" name="add_food" class="btn btn-success">Thêm Món</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>