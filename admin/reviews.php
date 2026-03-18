<?php
require_once '../api/db_connect.php';

// Xử lý Xóa đánh giá
if (isset($_GET['delete_id'])) {
    $del_id = (int)$_GET['delete_id'];
    $conn->query("DELETE FROM reviews WHERE id = $del_id");
    header("Location: reviews.php");
    exit;
}

$sql = "SELECT r.*, u.name as customer_name, f.name as food_name 
        FROM reviews r 
        JOIN users u ON r.customer_id = u.id 
        JOIN foods f ON r.food_id = f.id 
        ORDER BY r.created_at DESC";
$result = $conn->query($sql);

$page_title = "Quản lý Đánh giá";
include 'includes/sidebar.php'; 
?>

<div class="card shadow mb-4">
    <div class="card-body table-responsive">
        <table class="table table-bordered table-hover">
            <thead class="thead-light">
                <tr>
                    <th width="5%" class="text-center">STT</th>
                    <th width="10%">Mã ĐH</th>
                    <th width="15%">Khách hàng</th>
                    <th width="20%">Món ăn</th>
                    <th width="15%">Đánh giá</th>
                    <th width="25%">Nội dung (Bình luận)</th>
                    <th width="10%" class="text-center">Xóa</th>
                </tr>
            </thead>
            <tbody>
                <?php 
                $stt = 1;
                while($row = $result->fetch_assoc()): 
                ?>
                <tr>
                    <td class="text-center align-middle font-weight-bold"><?= $stt++ ?></td>
                    <td class="align-middle"><a href="order_detail.php?id=<?= $row['order_id'] ?>">#EPC-<?= $row['order_id'] ?></a></td>
                    <td class="align-middle"><strong><?= $row['customer_name'] ?></strong></td>
                    <td class="align-middle"><?= $row['food_name'] ?></td>
                    <td class="align-middle">
                        <div class="text-warning">
                            <?php 
                                $rating = (int)$row['rating'];
                                for($i=1; $i<=5; $i++) echo $i <= $rating ? '<i class="fas fa-star"></i>' : '<i class="far fa-star"></i>';
                            ?>
                        </div>
                    </td>
                    <td class="align-middle">
                        <?= empty($row['comment']) ? '<span class="text-muted font-italic">Không có bình luận</span>' : $row['comment'] ?>
                    </td>
                    <td class="text-center align-middle">
                        <a href="reviews.php?delete_id=<?= $row['id'] ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Xóa đánh giá này?');">
                            <i class="fas fa-trash"></i>
                        </a>
                    </td>
                </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    </div>
</div>

<?php include 'includes/footer.php'; ?>