<?php
// Lấy tên file hiện tại để làm sáng (active) menu
$current_page = basename($_SERVER['PHP_SELF']);
$page_title = $page_title ?? 'Epicure Admin'; // Nhận title từ trang gọi nó
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $page_title ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fc; overflow-x: hidden; }
        #wrapper { display: flex; width: 100vw; min-height: 100vh; }
        #page-content-wrapper { flex: 1; overflow-y: auto; background-color: #f8f9fc; }
        
        #sidebar { width: 250px; background: #2D1B4D; color: white; flex-shrink: 0; }
        #sidebar .sidebar-brand { padding: 20px; font-weight: 800; font-size: 1.2rem; letter-spacing: 2px; color: #D4AF37; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        #sidebar .nav-link { color: rgba(255,255,255,.8); padding: 15px 20px; font-weight: 600; transition: 0.2s; }
        #sidebar .nav-link:hover, #sidebar .nav-link.active { color: #D4AF37; background: rgba(255,255,255,.05); border-left: 4px solid #D4AF37; }
        #sidebar .nav-link i { width: 25px; text-align: center; margin-right: 10px; }
        
        .border-left-primary { border-left: .25rem solid #4e73df !important; }
        .border-left-success { border-left: .25rem solid #1cc88a !important; }
        .border-left-info { border-left: .25rem solid #36b9cc !important; }
        .border-left-warning { border-left: .25rem solid #f6c23e !important; }
    </style>
</head>
<body>
    <div id="wrapper">
        <!-- SIDEBAR -->
        <div id="sidebar" class="shadow-lg">
            <div class="sidebar-brand"><i class="fas fa-utensils"></i> EPICURE</div>
            <ul class="nav flex-column mt-3">
                <li class="nav-item"><a class="nav-link <?= $current_page == 'index.php' ? 'active' : '' ?>" href="index.php"><i class="fas fa-tachometer-alt"></i> Tổng quan</a></li>
                <li class="nav-item"><a class="nav-link <?= $current_page == 'orders.php' ? 'active' : '' ?>" href="orders.php"><i class="fas fa-receipt"></i> Quản lý Đơn hàng</a></li>
                <li class="nav-item"><a class="nav-link <?= $current_page == 'users.php' ? 'active' : '' ?>" href="users.php"><i class="fas fa-users"></i> Quản lý Người dùng</a></li>
                <li class="nav-item"><a class="nav-link <?= $current_page == 'drivers.php' ? 'active' : '' ?>" href="drivers.php"><i class="fas fa-id-badge"></i> Đối tác Tài xế</a></li>
                <li class="nav-item"><a class="nav-link <?= $current_page == 'foods.php' ? 'active' : '' ?>" href="foods.php"><i class="fas fa-hamburger"></i> Thực đơn & Tùy chọn</a></li>
                <li class="nav-item"><a class="nav-link <?= $current_page == 'withdrawals.php' ? 'active' : '' ?>" href="withdrawals.php"><i class="fas fa-wallet"></i> Yêu cầu Rút tiền</a></li>
                <li class="nav-item"><a class="nav-link <?= $current_page == 'reviews.php' ? 'active' : '' ?>" href="reviews.php"><i class="fas fa-star"></i> Đánh giá Món ăn</a></li>
            </ul>
        </div>

        <!-- TOPBAR & NỘI DUNG CHÍNH -->
        <div id="page-content-wrapper">
            <nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom shadow-sm mb-4 px-4 py-3">
                <span class="navbar-brand mb-0 h4 font-weight-bold text-gray-800"><?= $page_title ?></span>
                <div class="ml-auto d-flex align-items-center">
                    <span class="mr-3 text-gray-600 font-weight-bold">Xin chào, Admin!</span>
                    <img class="img-profile rounded-circle" src="https://ui-avatars.com/api/?name=Admin&background=2D1B4D&color=fff" width="40">
                </div>
            </nav>
            <div class="container-fluid px-4">
            <!-- NỘI DUNG TỪNG TRANG SẼ NẰM Ở ĐÂY -->