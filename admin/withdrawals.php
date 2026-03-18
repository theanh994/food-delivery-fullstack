<?php
require_once '../api/db_connect.php';

$sql = "SELECT w.*, u.name, u.phone, dw.balance 
        FROM withdrawal_requests w 
        JOIN users u ON w.driver_id = u.id 
        JOIN driver_wallets dw ON w.driver_id = dw.driver_id 
        ORDER BY w.created_at DESC";
$result = $conn->query($sql);
?>
<!-- ... (HTML Boilerplate tương tự orders.php) ... -->
<body class="bg-light p-4">
    <h2>Yêu cầu Rút tiền (Tài xế)</h2>
    <table class="table table-bordered bg-white">
        <thead class="thead-dark"><tr><th>Mã YC</th><th>Tài xế</th><th>SĐT</th><th>Số dư ví</th><th>Số tiền rút</th><th>Ngày YC</th><th>Hành động</th></tr></thead>
        <tbody>
            <?php while($row = $result->fetch_assoc()): ?>
            <tr>
                <td>#WD-<?= $row['id'] ?></td>
                <td><strong><?= $row['name'] ?></strong></td>
                <td><?= $row['phone'] ?></td>
                <td class="text-success font-weight-bold"><?= number_format($row['balance']) ?>đ</td>
                <td class="text-danger font-weight-bold"><?= number_format($row['amount']) ?>đ</td>
                <td><?= date('d/m/Y H:i', strtotime($row['created_at'])) ?></td>
                <td>
                    <?php if($row['status'] == 'pending'): ?>
                        <a href="approve_withdrawal.php?id=<?= $row['id'] ?>&action=approve" class="btn btn-sm btn-success" onclick="return confirm('Xác nhận đã chuyển khoản cho tài xế?')">Duyệt</a>
                        <a href="approve_withdrawal.php?id=<?= $row['id'] ?>&action=reject" class="btn btn-sm btn-danger">Từ chối</a>
                    <?php else: ?>
                        <span class="badge badge-secondary"><?= strtoupper($row['status']) ?></span>
                    <?php endif; ?>
                </td>
            </tr>
            <?php endwhile; ?>
        </tbody>
    </table>
</body>
</html>