import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart';

class DriverPendingScreen extends StatelessWidget {
  const DriverPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, size: 100, color: AppTheme.bronzeGold),
            const SizedBox(height: 40),
            const Text("Hồ sơ đang chờ duyệt", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text("Quản trị viên đang kiểm tra thông tin của bạn. Vui lòng quay lại sau 24h.", textAlign: TextAlign.center),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                final user = context.read<AuthProvider>().currentUser!;
                context.read<DriverProvider>().checkDriverStatus(user.id);
              },
              child: const Text("TẢI LẠI TRẠNG THÁI"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Đăng xuất"),
            )
          ],
        ),
      ),
    );
  }
}