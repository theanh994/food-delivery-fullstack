import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_endpoints.dart'; // THÊM DÒNG NÀY để sửa lỗi ApiEndpoints

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ cá nhân"), actions: [IconButton(icon: const Icon(Icons.more_horiz), onPressed: (){})]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header: Avatar & Name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.bronzeGold.withValues(alpha: 0.1),
                    backgroundImage: user?.avatar != null ? NetworkImage("${ApiEndpoints.baseUrl}/../${user!.avatar}") : null,
                    child: user?.avatar == null ? const Icon(Icons.person, size: 60, color: AppTheme.bronzeGold) : null,
                  ),
                  const SizedBox(height: 15),
                  Text(user?.name ?? "Người dùng", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // Card: Driver Switch (Dành riêng cho đối tác)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.darkPurple, Color(0xFF2e1065)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Chế độ hiện tại: Khách hàng", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Icon(Icons.local_taxi, color: AppTheme.bronzeGold),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Logic chuyển sang màn hình Driver (Sprint 7)
                        Navigator.pushReplacementNamed(context, '/driver_home');
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text("CHUYỂN SANG GIAO DIỆN TÀI XẾ"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bronzeGold, foregroundColor: AppTheme.darkPurple),
                    )
                  ],
                ),
              ),
            ),

            // Menu List
            _buildMenuItem(Icons.edit, "Chỉnh sửa thông tin", "Tên, ảnh và liên lạc", () => Navigator.pushNamed(context, '/edit_profile')),
            _buildMenuItem(Icons.lock, "Đổi mật khẩu", "Bảo mật tài khoản", () => Navigator.pushNamed(context, '/change_password')),
            _buildMenuItem(Icons.map, "Địa chỉ của tôi", "Nhà riêng, văn phòng...", () => Navigator.pushNamed(context, '/address_book')),
            
            const SizedBox(height: 30),
            
            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () { auth.logout(); Navigator.pushReplacementNamed(context, '/login'); },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(double.infinity, 50)),
                child: const Text("ĐĂNG XUẤT"),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.bronzeGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.bronzeGold)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}