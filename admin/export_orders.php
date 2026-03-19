<?php
require_once '../api/vendor/autoload.php'; // Load thư viện qua Composer
require_once '../api/db_connect.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

// 1. Nhận các bộ lọc
$status_filter = isset($_GET['status']) ? $conn->real_escape_string($_GET['status']) : '';
$date_filter = isset($_GET['order_date']) ? $conn->real_escape_string($_GET['order_date']) : '';

$sql = "SELECT o.id, u.name as customer, d.name as driver, o.total_amount, o.shipping_fee, o.final_amount, o.status, o.created_at 
        FROM orders o 
        JOIN users u ON o.customer_id = u.id 
        LEFT JOIN users d ON o.driver_id = d.id 
        WHERE 1=1 ";

if ($status_filter != '') $sql .= " AND o.status = '$status_filter' ";
if ($date_filter != '') $sql .= " AND DATE(o.created_at) = '$date_filter' ";
$sql .= " ORDER BY o.created_at DESC";
$result = $conn->query($sql);

// 2. Khởi tạo bảng tính Excel
$spreadsheet = new Spreadsheet();
$activeWorksheet = $spreadsheet->getActiveSheet();
$activeWorksheet->setTitle('Danh sách đơn hàng');

// 3. Đặt tiêu đề cột (Hàng 1)
$headers = ['Mã Đơn', 'Khách hàng', 'Tài xế', 'Tiền món (đ)', 'Phí ship (đ)', 'Tổng thu (đ)', 'Trạng thái', 'Ngày đặt'];
$columnIndex = 'A';
foreach ($headers as $header) {
    $activeWorksheet->setCellValue($columnIndex . '1', $header);
    // In đậm tiêu đề
    $activeWorksheet->getStyle($columnIndex . '1')->getFont()->setBold(true);
    // Tự động căn độ rộng cột
    $activeWorksheet->getColumnDimension($columnIndex)->setAutoSize(true);
    $columnIndex++;
}

// 4. Đổ dữ liệu từ Database (Bắt đầu từ hàng 2)
$rowNum = 2;
while ($row = $result->fetch_assoc()) {
    $activeWorksheet->setCellValue('A' . $rowNum, '#EPC-' . $row['id']);
    $activeWorksheet->setCellValue('B' . $rowNum, $row['customer']);
    $activeWorksheet->setCellValue('C' . $rowNum, $row['driver'] ?? 'Chưa nhận');
    $activeWorksheet->setCellValue('D' . $rowNum, $row['total_amount']);
    $activeWorksheet->setCellValue('E' . $rowNum, $row['shipping_fee']);
    $activeWorksheet->setCellValue('F' . $rowNum, $row['final_amount']);
    $activeWorksheet->setCellValue('G' . $rowNum, strtoupper($row['status']));
    $activeWorksheet->setCellValue('H' . $rowNum, $row['created_at']);
    
    // Định dạng số cho các cột tiền
    $activeWorksheet->getStyle('D'.$rowNum.':F'.$rowNum)->getNumberFormat()->setFormatCode('#,##0');
    
    $rowNum++;
}

// 5. Thiết lập Header để trình duyệt tải về file .xlsx
$filename = "Bao-cao-don-hang-" . date('d-m-Y') . ".xlsx";
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment;filename="' . $filename . '"');
header('Cache-Control: max-age=0');

$writer = new Xlsx($spreadsheet);
$writer->save('php://output'); // Xuất trực tiếp ra trình duyệt
exit;