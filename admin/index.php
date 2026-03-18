<?php
require_once '../api/db_connect.php';

// --- 1. LẤY SỐ LIỆU THỐNG KÊ CHI TIẾT ---

// Tổng doanh thu (Đơn completed)
$revenue_res = $conn->query("SELECT SUM(final_amount) as total FROM orders WHERE status = 'completed'")->fetch_assoc();
$total_revenue = $revenue_res['total'] ?? 0;

// Đơn hàng đang chờ xử lý (Action required)
$pending_orders_res = $conn->query("SELECT COUNT(*) as total FROM orders WHERE status = 'pending'")->fetch_assoc();
$pending_orders = $pending_orders_res['total'] ?? 0;

// Khách hàng & Tài xế
$users_count = $conn->query("SELECT COUNT(*) as total FROM users WHERE role = 'customer'")->fetch_assoc()['total'] ?? 0;
$drivers_count = $conn->query("SELECT COUNT(*) as total FROM users WHERE role = 'driver'")->fetch_assoc()['total'] ?? 0;

// --- 2. LẤY DỮ LIỆU BIỂU ĐỒ (7 ngày gần nhất) ---
$chart_data = [];
$days = [];
$revenues = [];

for ($i = 6; $i >= 0; $i--) {
    $date = date('Y-m-d', strtotime("-$i days"));
    $label = date('d/m', strtotime($date));
    
    $res = $conn->query("SELECT SUM(final_amount) as daily_total FROM orders 
                         WHERE status = 'completed' AND DATE(created_at) = '$date'")->fetch_assoc();
    
    $days[] = $label;
    $revenues[] = (float)($res['daily_total'] ?? 0);
}

// --- 3. DANH SÁCH 5 ĐƠN HÀNG MỚI NHẤT ---
$latest_orders = $conn->query("SELECT o.*, u.name as customer_name 
                               FROM orders o 
                               JOIN users u ON o.customer_id = u.id 
                               ORDER BY o.created_at DESC LIMIT 5");

$page_title = "Tổng Quan Hệ Thống";
include 'includes/sidebar.php'; 
?>

<!-- HÀNG 1: THẺ CHỈ SỐ (KPI CARDS) -->
<div class="row">
    <!-- Tổng Doanh Thu -->
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-primary shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Tổng doanh thu</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800"><?= number_format($total_revenue) ?>đ</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-coins fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Đơn Hàng Cần Xử Lý -->
    <div class="col-xl-3 col-md-6 mb-4">
        <a href="orders.php?status=pending" style="text-decoration: none;">
            <div class="card border-left-warning shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Đơn đang chờ</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $pending_orders ?> Đơn hàng</div>
                        </div>
                        <div class="col-auto"><i class="fas fa-clock fa-2x text-gray-300"></i></div>
                    </div>
                </div>
            </div>
        </a>
    </div>

    <!-- Tổng Khách Hàng -->
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-info shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Khách hàng</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $users_count ?> User</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-users fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tổng Tài Xế -->
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="card border-left-success shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Tài xế</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $drivers_count ?> Bác tài</div>
                    </div>
                    <div class="col-auto"><i class="fas fa-motorcycle fa-2x text-gray-300"></i></div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <!-- CỘT TRÁI: BIỂU ĐỒ DOANH THU -->
    <div class="col-xl-8 col-lg-7">
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                <h6 class="m-0 font-weight-bold text-primary">Biểu đồ doanh thu (7 ngày qua)</h6>
            </div>
            <div class="card-body">
                <div class="chart-area">
                    <canvas id="revenueChart" style="height: 300px;"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- CỘT PHẢI: ĐƠN HÀNG MỚI NHẤT -->
    <div class="col-xl-4 col-lg-5">
        <div class="card shadow mb-4">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-primary">5 Đơn hàng mới nhất</h6>
            </div>
            <div class="card-body p-0">
                <div class="list-group list-group-flush">
                    <?php while($o = $latest_orders->fetch_assoc()): ?>
                    <a href="order_detail.php?id=<?= $o['id'] ?>" class="list-group-item list-group-item-action">
                        <div class="d-flex w-100 justify-content-between">
                            <h6 class="mb-1 font-weight-bold">#EPC-<?= $o['id'] ?></h6>
                            <small class="text-muted"><?= date('H:i', strtotime($o['created_at'])) ?></small>
                        </div>
                        <p class="mb-1 small text-dark"><?= $o['customer_name'] ?> - <strong><?= number_format($o['final_amount']) ?>đ</strong></p>
                        <small class="badge badge-warning text-dark uppercase"><?= $o['status'] ?></small>
                    </a>
                    <?php endwhile; ?>
                </div>
                <div class="p-3 text-center">
                    <a href="orders.php" class="small font-weight-bold">Xem tất cả đơn hàng &rarr;</a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Scripts cho Biểu đồ -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const ctx = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: <?= json_encode($days) ?>,
            datasets: [{
                label: 'Doanh thu (VNĐ)',
                data: <?= json_encode($revenues) ?>,
                backgroundColor: 'rgba(78, 115, 223, 0.05)',
                borderColor: '#2D1B4D',
                pointBackgroundColor: '#D4AF37',
                pointBorderColor: '#D4AF37',
                tension: 0.3,
                fill: true
            }]
        },
        options: {
            maintainAspectRatio: false,
            scales: {
                y: { beginAtZero: true, grid: { drawBorder: false } },
                x: { grid: { display: false } }
            },
            plugins: { legend: { display: false } }
        }
    });
</script>

<?php include 'includes/footer.php'; ?>