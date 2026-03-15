import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NotiType { success, error, info }

class AppNoti {
  static void show(BuildContext context, String message, {NotiType type = NotiType.info}) {
    // Xác định màu sắc và icon dựa trên loại thông báo
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case NotiType.success:
        backgroundColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case NotiType.error:
        backgroundColor = Colors.red.shade800;
        icon = Icons.error_outline;
        break;
      case NotiType.info:
        backgroundColor = AppTheme.darkPurple;
        icon = Icons.info_outline;
        break;
    }

    // Xóa các thông báo cũ đang hiện để tránh chồng chéo
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.bronzeGold, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor.withValues(alpha: 0.95), // Trong suốt nhẹ
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Quan trọng: Làm nó nổi lên
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30), // Đẩy cách đáy và 2 bên
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Bo tròn cực đại
          side: BorderSide(color: AppTheme.bronzeGold.withValues(alpha: 0.5), width: 1),
        ),
        elevation: 10,
      ),
    );
  }
}