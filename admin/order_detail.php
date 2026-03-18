<?php
require_once '../api/db_connect.php';
$id = (int)$_GET['id'];

// Xử lý Hủy khẩn cấp
if (isset($_POST['force_cancel'])) {
    $conn->query("UPDATE orders SET status = 'cancelled' WHERE id = $id");
    $conn->query("INSERT INTO notifications (user_id, title, message) VALUES ((SELECT customer_id FROM orders WHERE id=$id), 'Đơn hàng bị hủy', 'Hệ thống đã hủy đơn hàng #EPC-$id của bạn do sự cố bất khả kháng.')");
    header("Location: order_detail.php?id=$id"); exit;
}

$order = $conn->query("SELECT o.*, c.name as c_name, c.phone as c_phone, d.name as d_name, d.phone as d_phone FROM orders o JOIN users c ON o.customer_id = c.id LEFT JOIN users d ON o.driver_id = d.id WHERE o.id = $id")->fetch_assoc();
$details = $conn->query("SELECT d.*, f.name FROM order_details d JOIN foods f ON d.food_id = f.id WHERE d.order_id = $id");

$page_title = "Chi tiết Đơn hàng #EPC-" . $id;
include 'includes/sidebar.php'; 
?>

<!-- CSS ẨN CÁC PHẦN THỪA KHI IN HÓA ĐƠN -->
<style>
    @media print {
        body * { visibility: hidden; }
        #invoice-area, #invoice-area * { visibility: visible; }
        #invoice-area { position: absolute; left: 0; top: 0; width: 100%; padding: 20px; }
        .no-print { display: none !important; }
        .card { border: none !important; box-shadow: none !important; }
    }
</style>

<!-- Thanh công cụ (Sẽ bị ẩn khi in) -->
<div class="d-flex justify-content-between align-items-center mb-4 no-print">
    <a href="orders.php" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Trở về</a>
    <div>
        <button onclick="window.print()" class="btn btn-success mr-2"><i class="fas fa-print"></i> Xuất Hóa Đơn (In)</button>
        <?php if(!in_array($order['status'], ['completed', 'cancelled'])): ?>
        <form method="POST" class="d-inline" onsubmit="return confirm('CẢNH BÁO: Hủy khẩn cấp sẽ hoàn tiền (nếu có) và đóng đơn hàng này lại?');">
            <button type="submit" name="force_cancel" class="btn btn-danger"><i class="fas fa-ban"></i> Hủy Đơn Khẩn Cấp</button>
        </form>
        <?php endif; ?>
    </div>
</div>

<!-- KHU VỰC HÓA ĐƠN (Sẽ được in ra) -->
<div id="invoice-area" class="card shadow mb-4">
    <div class="card-body p-5">
        
        <!-- Header Hóa Đơn -->
        <div class="row border-bottom pb-4 mb-4">
            <div class="col-sm-6">
                <h2 class="font-weight-bold" style="color: #2D1B4D;"><i class="fas fa-utensils"></i> EPICURE</h2>
                <p class="text-muted mb-0">Hệ thống đặt đồ ăn & Giao hàng siêu tốc</p>
                <p class="text-muted mb-0">Hotline: 1900 1234</p>
            </div>
            <div class="col-sm-6 text-sm-right">
                <h4 class="font-weight-bold text-uppercase">HÓA ĐƠN BÁN HÀNG</h4>
                <p class="mb-0"><strong>Mã đơn:</strong> #EPC-<?= $order['id'] ?></p>
                <p class="mb-0"><strong>Ngày tạo:</strong> <?= date('d/m/Y H:i', strtotime($order['created_at'])) ?></p>
                <p class="mb-0"><strong>Trạng thái:</strong> <?= strtoupper($order['status']) ?></p>
            </div>
        </div>

        <!-- Thông tin Khách & Tài xế -->
        <div class="row mb-5">
            <div class="col-sm-6">
                <h6 class="text-muted font-weight-bold text-uppercase">Thông tin Người nhận</h6>
                <p class="mb-1"><strong>Khách hàng:</strong> <?= $order['c_name'] ?></p>
                <p class="mb-1"><strong>Điện thoại:</strong> <?= $order['c_phone'] ?></p>
                <p class="mb-1"><strong>Giao đến:</strong> <?= $order['delivery_address'] ?></p>
                <?php if($order['order_note']): ?>
                    <p class="mb-1 text-danger"><strong>Ghi chú:</strong> <?= $order['order_note'] ?></p>
                <?php endif; ?>
            </div>
            <div class="col-sm-6 text-sm-right">
                <h6 class="text-muted font-weight-bold text-uppercase">Thông tin Đối tác giao hàng</h6>
                <?php if($order['driver_id']): ?>
                    <p class="mb-1"><strong>Tài xế:</strong> <?= $order['d_name'] ?></p>
                    <p class="mb-1"><strong>Điện thoại:</strong> <?= $order['d_phone'] ?></p>
                <?php else: ?>
                    <p class="text-muted font-italic">Chưa có tài xế nhận đơn</p>
                <?php endif; ?>
            </div>
        </div>

        <!-- Danh sách món -->
        <table class="table table-bordered">
            <thead class="thead-light">
                <tr>
                    <th width="5%" class="text-center">STT</th>
                    <th width="45%">Món ăn & Tùy chọn</th>
                    <th width="10%" class="text-center">SL</th>
                    <th width="20%" class="text-right">Đơn giá</th>
                    <th width="20%" class="text-right">Thành tiền</th>
                </tr>
            </thead>
            <tbody>
                <?php $stt=1; while($item = $details->fetch_assoc()): ?>
                <tr>
                    <td class="text-center"><?= $stt++ ?></td>
                    <td>
                        <strong><?= $item['name'] ?></strong>
                        <?php if($item['item_note']): ?>
                            <br><small class="text-muted font-italic"><?= $item['item_note'] ?></small>
                        <?php endif; ?>
                    </td>
                    <td class="text-center"><?= $item['quantity'] ?></td>
                    <td class="text-right"><?= number_format($item['unit_price']) ?>đ</td>
                    <td class="text-right font-weight-bold"><?= number_format($item['unit_price'] * $item['quantity']) ?>đ</td>
                </tr>
                <?php endwhile; ?>
            </tbody>
        </table>

        <!-- Tính tổng tiền -->
        <div class="row mt-4">
            <div class="col-sm-7">
                <p class="text-muted font-italic">Lưu ý: Hóa đơn này có giá trị xác nhận thanh toán khi trạng thái đơn hàng là COMPLETED.</p>
            </div>
            <div class="col-sm-5">
                <table class="table table-sm table-borderless">
                    <tr>
                        <td><strong>Tạm tính:</strong></td>
                        <td class="text-right"><?= number_format($order['total_amount']) ?>đ</td>
                    </tr>
                    <tr>
                        <td><strong>Phí giao hàng:</strong></td>
                        <td class="text-right"><?= number_format($order['shipping_fee']) ?>đ</td>
                    </tr>
                    <tr class="border-top">
                        <td><h5 class="font-weight-bold mb-0">TỔNG THANH TOÁN:</h5></td>
                        <td class="text-right"><h5 class="font-weight-bold text-danger mb-0"><?= number_format($order['final_amount']) ?>đ</h5></td>
                    </tr>
                </table>
            </div>
        </div>

    </div>
</div>

<?php include 'includes/footer.php'; ?>