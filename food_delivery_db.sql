-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th3 19, 2026 lúc 09:09 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `food_delivery_db`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('active','hidden') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`id`, `name`, `image_url`, `status`, `created_at`) VALUES
(1, 'Thức uống Đặc biệt', NULL, 'active', '2026-03-18 15:11:33'),
(2, 'Món chính Thượng hạng', NULL, 'active', '2026-03-18 15:11:33'),
(3, 'Bánh & Tráng miệng', NULL, 'active', '2026-03-18 15:11:33'),
(4, 'Món khai vị', NULL, 'active', '2026-03-18 15:11:33');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `driver_profiles`
--

CREATE TABLE `driver_profiles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vehicle_type` varchar(50) DEFAULT NULL,
  `vehicle_plate` varchar(20) DEFAULT NULL,
  `license_image` varchar(255) DEFAULT NULL,
  `portrait_image` varchar(255) DEFAULT NULL,
  `status` enum('unverified','pending','approved') DEFAULT 'unverified',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `driver_profiles`
--

INSERT INTO `driver_profiles` (`id`, `user_id`, `vehicle_type`, `vehicle_plate`, `license_image`, `portrait_image`, `status`, `created_at`) VALUES
(1, 7, 'Honda Wave', '17B-56281', 'uploads/drivers/license_7_1773682798.jpg', 'uploads/drivers/portrait_7_1773682798.jpg', 'approved', '2026-03-16 17:39:58');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `driver_wallets`
--

CREATE TABLE `driver_wallets` (
  `driver_id` int(11) NOT NULL,
  `balance` decimal(12,2) DEFAULT 0.00,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `driver_wallets`
--

INSERT INTO `driver_wallets` (`driver_id`, `balance`, `updated_at`) VALUES
(7, 15000.00, '2026-03-17 17:09:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `foods`
--

CREATE TABLE `foods` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `food_type` enum('drink','food') DEFAULT 'food',
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `foods`
--

INSERT INTO `foods` (`id`, `category_id`, `food_type`, `name`, `description`, `price`, `image_url`, `is_available`, `created_at`) VALUES
(1, 1, 'drink', 'Trà Ô long nướng', 'Hương vị trà đậm đà, thơm mùi khói đặc trưng từ quy trình nướng thủ công.', 45000.00, 'https://picsum.photos/id/225/400/300', 1, '2026-03-18 15:11:33'),
(2, 1, 'drink', 'Matcha Latte', 'Bột matcha chuẩn Nhật Bản kết hợp sữa tươi nguyên kem béo ngậy.', 55000.00, 'https://picsum.photos/id/102/400/300', 1, '2026-03-18 15:11:33'),
(3, 1, 'drink', 'Trà Trái cây Nhiệt đới', 'Sự kết hợp tươi mát từ dứa, cam, và chanh dây kèm hạt chia bổ dưỡng.', 49000.00, 'https://picsum.photos/id/429/400/300', 1, '2026-03-18 15:11:33'),
(4, 1, 'drink', 'Caramel Macchiato', 'Cà phê Espresso đậm đặc hòa quyện cùng sốt caramel ngọt ngào.', 65000.00, 'https://picsum.photos/id/63/400/300', 1, '2026-03-18 15:11:33'),
(5, 2, 'food', 'Mì Ý Sốt Truffle', 'Sợi mì Linguine quyện trong sốt kem nấm Truffle đen quý hiếm.', 185000.00, 'https://picsum.photos/id/493/400/300', 1, '2026-03-18 15:11:33'),
(6, 2, 'food', 'Thăn bò Wagyu Áp chảo', 'Bò Wagyu thượng hạng dùng kèm sốt rượu vang đỏ và khoai tây nghiền.', 450000.00, 'https://picsum.photos/id/635/400/300', 1, '2026-03-18 15:11:33'),
(7, 2, 'food', 'Cá hồi Na Uy nướng', 'Cá hồi tươi nướng mộc với lá hương thảo và măng tây.', 295000.00, 'https://picsum.photos/id/674/400/300', 1, '2026-03-18 15:11:33'),
(8, 3, 'food', 'Cheesecake New York', 'Bánh phô mai nướng kiểu Mỹ với đế bánh quy giòn tan.', 85000.00, 'https://picsum.photos/id/312/400/300', 1, '2026-03-18 15:11:33'),
(9, 3, 'food', 'Chocolate Lava Cake', 'Bánh chocolate tan chảy dùng kèm một viên kem vani Pháp.', 95000.00, 'https://picsum.photos/id/431/400/300', 1, '2026-03-18 15:11:33'),
(10, 4, 'food', 'Bánh mì bơ tỏi đặc biệt', 'Bánh mì nướng giòn rụm với sốt bơ tỏi và phô mai kéo sợi.', 35000.00, 'https://picsum.photos/id/1060/400/300', 1, '2026-03-18 15:11:33'),
(11, 2, 'food', 'Burger Bò Angus', 'Bánh mì thủ công kẹp thịt bò Angus nướng và trứng ốp la.', 120000.00, 'https://picsum.photos/id/1080/400/300', 1, '2026-03-18 15:11:33');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `is_read`, `created_at`) VALUES
(42, 2, 'Đặt hàng thành công', 'Đơn hàng #EPC-1 của bạn đã được tiếp nhận và đang chờ xác nhận.', 0, '2026-03-18 15:16:30'),
(43, 2, 'Đơn hàng bị hủy', 'Hệ thống đã hủy đơn hàng #EPC-1 của bạn do sự cố bất khả kháng.', 0, '2026-03-18 15:16:55'),
(44, 2, 'Đặt hàng thành công', 'Đơn hàng #EPC-2 của bạn đã được tiếp nhận và đang chờ xác nhận.', 0, '2026-03-19 15:11:19'),
(45, 2, 'Cập nhật đơn hàng', 'Tài xế đã lấy món và đang trên đường giao đến bạn.', 0, '2026-03-19 15:15:37'),
(46, 2, 'Đặt hàng thành công', 'Đơn hàng #EPC-3 của bạn đã được tiếp nhận và đang chờ xác nhận.', 0, '2026-03-19 18:14:34'),
(47, 2, 'Đơn hàng đã hủy', 'Bạn đã hủy đơn #EPC-3 thành công.', 0, '2026-03-19 18:14:45'),
(48, 2, 'Đặt hàng thành công', 'Đơn hàng #EPC-4 của bạn đã được tiếp nhận và đang chờ xác nhận.', 0, '2026-03-19 19:10:32'),
(49, 2, 'Đặt hàng thành công', 'Đơn hàng #EPC-5 của bạn đã được tiếp nhận và đang chờ xác nhận.', 0, '2026-03-19 19:11:11'),
(50, 2, 'Đơn hàng đã hủy', 'Bạn đã hủy đơn #EPC-5 thành công.', 0, '2026-03-19 19:11:20'),
(51, 2, 'Đơn hàng đã hủy', 'Bạn đã hủy đơn #EPC-4 thành công.', 0, '2026-03-19 19:11:24');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `option_groups`
--

CREATE TABLE `option_groups` (
  `id` int(11) NOT NULL,
  `food_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `is_required` tinyint(1) DEFAULT 0,
  `is_multi_select` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `option_groups`
--

INSERT INTO `option_groups` (`id`, `food_id`, `name`, `is_required`, `is_multi_select`) VALUES
(1, 1, 'Chọn Kích cỡ', 1, 0),
(2, 1, 'Mức đường', 1, 0),
(3, 1, 'Mức đá', 1, 0),
(4, 1, 'Topping thêm', 0, 1),
(5, 5, 'Thêm Phô mai', 0, 0),
(6, 6, 'Độ chín thịt', 1, 0),
(7, 10, 'Mức độ cay', 1, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `option_items`
--

CREATE TABLE `option_items` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `extra_price` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `option_items`
--

INSERT INTO `option_items` (`id`, `group_id`, `name`, `extra_price`) VALUES
(1, 1, 'Size Vừa (M)', 0.00),
(2, 1, 'Size Lớn (L)', 10000.00),
(3, 2, '0% Đường', 0.00),
(4, 2, '50% Đường', 0.00),
(5, 2, '100% Đường', 0.00),
(6, 3, '0% Đá', 0.00),
(7, 3, '50% Đá', 0.00),
(8, 3, '100% Đá', 0.00),
(9, 4, 'Trân châu trắng', 7000.00),
(10, 4, 'Thạch dừa', 7000.00),
(11, 4, 'Kem Cheese', 15000.00),
(12, 5, 'Thêm phô mai sợi', 15000.00),
(13, 6, 'Tái (Rare)', 0.00),
(14, 6, 'Chín vừa (Medium)', 0.00),
(15, 6, 'Chín kỹ (Well-done)', 0.00),
(16, 7, 'Không cay', 0.00),
(17, 7, 'Cay vừa', 0.00),
(18, 7, 'Rất cay', 0.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `driver_id` int(11) DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `shipping_fee` decimal(10,2) DEFAULT 15000.00,
  `final_amount` decimal(10,2) NOT NULL,
  `delivery_address` text NOT NULL,
  `order_note` text DEFAULT NULL,
  `status` enum('pending','accepted','picking','delivering','completed','cancelled') DEFAULT 'pending',
  `payment_method` enum('cash') DEFAULT 'cash',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`id`, `customer_id`, `driver_id`, `total_amount`, `shipping_fee`, `final_amount`, `delivery_address`, `order_note`, `status`, `payment_method`, `created_at`, `updated_at`) VALUES
(1, 2, NULL, 95000.00, 15000.00, 110000.00, '111/58 yên lộ', '', 'cancelled', 'cash', '2026-03-18 15:16:30', '2026-03-18 15:16:55'),
(2, 2, 7, 55000.00, 15000.00, 70000.00, '111/58 yên lộ', '', 'delivering', 'cash', '2026-03-19 15:11:19', '2026-03-19 15:22:38'),
(3, 2, NULL, 55000.00, 15000.00, 50000.00, '111/58 yên lộ', '', 'cancelled', 'cash', '2026-03-19 18:14:34', '2026-03-19 18:14:45'),
(4, 2, NULL, 55000.00, 15000.00, 70000.00, '111/58 yên lộ', '', 'cancelled', 'cash', '2026-03-19 19:10:32', '2026-03-19 19:11:24'),
(5, 2, NULL, 55000.00, 15000.00, 70000.00, '111/58 yên lộ', '', 'cancelled', 'cash', '2026-03-19 19:11:11', '2026-03-19 19:11:20');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_chats`
--

CREATE TABLE `order_chats` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `order_chats`
--

INSERT INTO `order_chats` (`id`, `order_id`, `sender_id`, `message`, `created_at`) VALUES
(9, 2, 7, 'Chào bạn, mình là tài xế đây. Mình đang chờ lấy món nhé!', '2026-03-19 15:27:18');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_details`
--

CREATE TABLE `order_details` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `food_id` int(11) NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `unit_price` decimal(10,2) NOT NULL,
  `item_note` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `order_details`
--

INSERT INTO `order_details` (`id`, `order_id`, `food_id`, `quantity`, `unit_price`, `item_note`) VALUES
(1, 1, 9, 1, 95000.00, ''),
(2, 2, 1, 1, 55000.00, 'Chọn Kích cỡ: Size Lớn (L) | Mức đá: 100% Đá | Mức đường: 0% Đường'),
(3, 3, 1, 1, 55000.00, 'Chọn Kích cỡ: Size Lớn (L) | Mức đá: 100% Đá | Mức đường: 0% Đường'),
(4, 4, 1, 1, 55000.00, 'Chọn Kích cỡ: Size Lớn (L) | Mức đá: 100% Đá | Mức đường: 50% Đường'),
(5, 5, 1, 1, 55000.00, 'Chọn Kích cỡ: Size Lớn (L) | Mức đá: 100% Đá | Mức đường: 50% Đường');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `food_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('customer','driver','admin') DEFAULT 'customer',
  `is_banned` tinyint(1) DEFAULT 0,
  `avatar` varchar(255) DEFAULT NULL,
  `fcm_token` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `password`, `role`, `is_banned`, `avatar`, `fcm_token`, `created_at`) VALUES
(1, 'Khách Hàng VIP', 'khachhang@gmail.com', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer', 1, NULL, NULL, '2026-03-11 17:37:15'),
(2, 'Trần Thế Anh', 'theanht057@gmail.com', '0972937758', '$2y$10$4f4Z02/KjkrUxbAicd7myO7T6tVWerN2j1aHgLqkTM2nqO0PsR4Py', 'customer', 0, 'uploads/avatars/user_2_1773500461.jpg', 'ftCX7TAqQOSqxzosyQ0iF8:APA91bFexfXbWyFnVSzWNby8J-Jhxehqn_zYf_eXx3O0gdpq3MEvvhN8wEhYZEOAT2BzPjXFM-z6Yk8o-usfrOJwUN4pGLFTiwpzdcQn5VdldZOjW5mbQgA', '2026-03-11 18:37:38'),
(7, 'Trần Thế', 'theanh@gmail.com', '0972937759', '$2y$10$NMxd2PaXJMI5bOj8hDiieuZRY4xh2rcNtMCk2VgB079.g1/uPw7MK', 'driver', 0, NULL, NULL, '2026-03-16 17:23:18');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_addresses`
--

CREATE TABLE `user_addresses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(50) NOT NULL,
  `address_detail` text NOT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `user_addresses`
--

INSERT INTO `user_addresses` (`id`, `user_id`, `title`, `address_detail`, `is_default`, `created_at`) VALUES
(1, 2, 'Nhà riêng', '111/58 yên lộ', 0, '2026-03-14 14:29:13');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `vouchers`
--

CREATE TABLE `vouchers` (
  `id` int(11) NOT NULL,
  `code` varchar(20) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL,
  `min_spend` decimal(10,2) DEFAULT 0.00,
  `expiry_date` datetime NOT NULL,
  `usage_limit` int(11) DEFAULT 100,
  `used_count` int(11) DEFAULT 0,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `vouchers`
--

INSERT INTO `vouchers` (`id`, `code`, `discount_amount`, `min_spend`, `expiry_date`, `usage_limit`, `used_count`, `status`, `created_at`) VALUES
(1, 'XINCHAO', 20000.00, 50000.00, '2026-12-31 23:59:59', 100, 0, 'active', '2026-03-19 17:56:58'),
(2, 'FREESHIP', 15000.00, 0.00, '2026-12-31 23:59:59', 100, 0, 'active', '2026-03-19 17:56:58'),
(4, 'THEANHDEPTRAI', 99999.00, 99.00, '2026-09-09 00:00:00', 99, 0, 'active', '2026-03-19 18:21:37');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `type` enum('earning','withdrawal') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `withdrawal_requests`
--

CREATE TABLE `withdrawal_requests` (
  `id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `driver_profiles`
--
ALTER TABLE `driver_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `driver_wallets`
--
ALTER TABLE `driver_wallets`
  ADD PRIMARY KEY (`driver_id`);

--
-- Chỉ mục cho bảng `foods`
--
ALTER TABLE `foods`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `option_groups`
--
ALTER TABLE `option_groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `food_id` (`food_id`);

--
-- Chỉ mục cho bảng `option_items`
--
ALTER TABLE `option_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `driver_id` (`driver_id`);

--
-- Chỉ mục cho bảng `order_chats`
--
ALTER TABLE `order_chats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `sender_id` (`sender_id`);

--
-- Chỉ mục cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `food_id` (`food_id`);

--
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `food_id` (`food_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- Chỉ mục cho bảng `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `vouchers`
--
ALTER TABLE `vouchers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Chỉ mục cho bảng `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_id` (`driver_id`);

--
-- Chỉ mục cho bảng `withdrawal_requests`
--
ALTER TABLE `withdrawal_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_id` (`driver_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `driver_profiles`
--
ALTER TABLE `driver_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `foods`
--
ALTER TABLE `foods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT cho bảng `option_groups`
--
ALTER TABLE `option_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `option_items`
--
ALTER TABLE `option_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `order_chats`
--
ALTER TABLE `order_chats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `user_addresses`
--
ALTER TABLE `user_addresses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `withdrawal_requests`
--
ALTER TABLE `withdrawal_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `driver_profiles`
--
ALTER TABLE `driver_profiles`
  ADD CONSTRAINT `driver_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `driver_wallets`
--
ALTER TABLE `driver_wallets`
  ADD CONSTRAINT `driver_wallets_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `foods`
--
ALTER TABLE `foods`
  ADD CONSTRAINT `foods_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `option_groups`
--
ALTER TABLE `option_groups`
  ADD CONSTRAINT `option_groups_ibfk_1` FOREIGN KEY (`food_id`) REFERENCES `foods` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `option_items`
--
ALTER TABLE `option_items`
  ADD CONSTRAINT `option_items_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `option_groups` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `order_chats`
--
ALTER TABLE `order_chats`
  ADD CONSTRAINT `order_chats_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_chats_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `foods` (`id`);

--
-- Các ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`food_id`) REFERENCES `foods` (`id`);

--
-- Các ràng buộc cho bảng `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD CONSTRAINT `user_addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `withdrawal_requests`
--
ALTER TABLE `withdrawal_requests`
  ADD CONSTRAINT `withdrawal_requests_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
