import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart'; // Thêm import này
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/app_noti.dart'; // Import công cụ thông báo

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header: Avatar & Name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.bronzeGold.withValues(alpha: 0.1),
                    backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                        ? NetworkImage("${ApiEndpoints.baseUrl}/../${user.avatar}")
                        : null,
                    child: (user?.avatar == null || user!.avatar!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: AppTheme.bronzeGold)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(user?.name ?? "Người dùng",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // 2. PHẦN QUAN TRỌNG: LOGIC PHÂN QUYỀN HIỂN THỊ THẺ TÀI XẾ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: user?.role == 'driver'
                  ? _buildSwitchToDriverCard(context) // Đã là tài xế -> Hiện nút chuyển
                  : _buildBecomeDriverCard(context), // Là khách -> Hiện nút đăng ký
            ),

            // 3. Menu List
            const SizedBox(height: 10),
            _buildMenuItem(Icons.edit, "Chỉnh sửa thông tin", "Tên, ảnh và liên lạc",
                () => Navigator.pushNamed(context, '/edit_profile')),
            _buildMenuItem(Icons.lock, "Đổi mật khẩu", "Bảo mật tài khoản",
                () => Navigator.pushNamed(context, '/change_password')),
            _buildMenuItem(Icons.map, "Địa chỉ của tôi", "Nhà riêng, văn phòng...",
                () => Navigator.pushNamed(context, '/address_book')),
            _buildMenuItem(Icons.help_outline, "Hỗ trợ & Liên hệ", "Giải đáp thắc mắc và góp ý",
                () => Navigator.pushNamed(context, '/support')),

            const SizedBox(height: 30),

            // 4. Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("ĐĂNG XUẤT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 1: DÀNH CHO NGƯỜI ĐÃ LÀ TÀI XẾ (Hỗ trợ đổi qua lại) ---
  Widget _buildSwitchToDriverCard(BuildContext context) {
    // Kiểm tra xem màn hình hiện tại có phải thuộc luồng Driver không
    // Chúng ta dựa vào việc kiểm tra Route hiện tại là /driver_home hay /customer_home
    final bool isCurrentlyInDriverUI = ModalRoute.of(context)?.settings.name == '/driver_home';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentlyInDriverUI 
            ? [AppTheme.bronzeGold, const Color(0xFF8D6E63)] // Màu khác đi chút khi ở bản Driver
            : [AppTheme.darkPurple, const Color(0xFF2e1065)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentlyInDriverUI ? "CHẾ ĐỘ KHÁCH HÀNG" : "CHẾ ĐỘ TÀI XẾ",
                    style: TextStyle(
                      color: isCurrentlyInDriverUI ? AppTheme.darkPurple : AppTheme.bronzeGold, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                  Text(
                    isCurrentlyInDriverUI ? "Quay lại đặt món ăn" : "Dành riêng cho đối tác", 
                    style: TextStyle(
                      color: isCurrentlyInDriverUI ? Colors.black54 : Colors.white70, 
                      fontSize: 11
                    )
                  ),
                ],
              ),
              Icon(
                isCurrentlyInDriverUI ? Icons.restaurant : Icons.local_taxi, 
                color: isCurrentlyInDriverUI ? AppTheme.darkPurple : AppTheme.bronzeGold
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (isCurrentlyInDriverUI) {
                  // Đang ở giao diện Tài xế -> Chuyển về Khách
                  Navigator.pushReplacementNamed(context, '/customer_home');
                } else {
                  // Đang ở giao diện Khách -> Chuyển sang Tài xế (Cần check hồ sơ)
                  final userId = context.read<AuthProvider>().currentUser!.id;
                  await context.read<DriverProvider>().checkDriverStatus(userId);
                  
                  if (context.mounted) {
                    final status = context.read<DriverProvider>().status;
                    if (status == 'approved') {
                      Navigator.pushReplacementNamed(context, '/driver_home');
                    } else if (status == 'pending') {
                      Navigator.pushNamed(context, '/driver_pending');
                    } else {
                      Navigator.pushNamed(context, '/driver_registration');
                    }
                  }
                }
              },
              icon: const Icon(Icons.swap_horiz),
              label: Text(
                isCurrentlyInDriverUI ? "CHUYỂN SANG GIAO DIỆN KHÁCH" : "CHUYỂN SANG GIAO DIỆN NHẬN ĐƠN",
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyInDriverUI ? AppTheme.darkPurple : AppTheme.bronzeGold,
                foregroundColor: isCurrentlyInDriverUI ? AppTheme.bronzeGold : AppTheme.darkPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  // --- WIDGET 2: DÀNH CHO KHÁCH HÀNG (BECOME DRIVER) ---
  Widget _buildBecomeDriverCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.bronzeGold.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gia tăng thu nhập cùng Epicure?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkPurple)),
          const SizedBox(height: 8),
          const Text("Đăng ký trở thành đối tác giao hàng ngay hôm nay để nhận các quyền lợi hấp dẫn.",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () => _confirmBecomeDriver(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.bronzeGold,
              side: const BorderSide(color: AppTheme.bronzeGold),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("ĐĂNG KÝ LÀM TÀI XẾ", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Hàm xác nhận nâng cấp
  void _confirmBecomeDriver(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Trở thành Tài xế?"),
        content: const Text("Hệ thống sẽ cập nhật tài khoản của bạn sang vai trò Tài xế. Bạn có đồng ý không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Để sau")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple),
            onPressed: () async {
              final userId = context.read<AuthProvider>().currentUser!.id;
              bool ok = await context.read<AuthProvider>().becomeDriver(userId);
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                AppNoti.show(context, "Chúc mừng! Bạn đã là đối tác tài xế.", type: NotiType.success);
                // Dẫn đi nộp hồ sơ
                Navigator.pushNamed(context, '/driver_registration');
              }
            },
            child: const Text("Đồng ý", style: TextStyle(color: AppTheme.bronzeGold)),
          )
        ],
      ),
    );
  }

  // Widget MenuItem dùng chung
  Widget _buildMenuItem(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.bronzeGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.bronzeGold, size: 22)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}