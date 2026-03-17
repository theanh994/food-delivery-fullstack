import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_noti.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../chat/screens/chat_screen.dart'; // Đảm bảo đã có file này

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  // --- HÀM GỌI ĐIỆN ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // --- HÀM XÁC NHẬN HỦY ---
  void _confirmCancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Đóng")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final userId = context.read<AuthProvider>().currentUser!.id;
              bool success = await context.read<OrderProvider>().cancelOrder(order.id, userId);
              if (context.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  AppNoti.show(context, "Đã hủy đơn hàng thành công!", type: NotiType.success);
                  Navigator.pop(context); 
                } else {
                  AppNoti.show(context, "Không thể hủy đơn vào lúc này.", type: NotiType.error);
                }
              }
            },
            child: const Text("Xác nhận hủy", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tính toán thời gian 2 phút
    final int secondsPassed = DateTime.now().difference(order.createdAt).inSeconds;
    final bool isWithinTimeLimit = secondsPassed < 120;

    final steps = [
      {'status': 'pending', 'label': 'Đã xác nhận', 'icon': Icons.check_circle},
      {'status': 'accepted', 'label': 'Đang chuẩn bị', 'icon': Icons.restaurant},
      {'status': 'delivering', 'label': 'Đang giao hàng', 'icon': Icons.moped},
      {'status': 'completed', 'label': 'Giao thành công', 'icon': Icons.flag},
    ];

    int currentStepIndex = steps.indexWhere((s) => s['status'] == order.status);
    if (order.status == 'picking') currentStepIndex = 1;

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(title: const Text("Theo dõi đơn hàng"), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Phần Bản đồ
            Container(
              height: 200, width: double.infinity, margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAwqyMIjjfAubFD6OvU-I38IphjVvlpLT1enBUKwtLrzEvZ_PnRYoNW_bUq_kHjK4OXhMj6eC7H8-0q7HcQenBIzS7xEhtrtgsFs2nB9Tokf8YnxIfDkK_VPq1eHRTJihqNMeoNWO84W03buhje4KuAniqnxko0SQeu0-wA5qFo3rb69ZHn5QJwuLrXNR8Hfe5jm0JvaiztGeq0a5tUzpneQFFa1kVEwxAh8li1yJ74MBDV87n8xLfR5I8TeFBVHqqX4z7FVcXrdOZY"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Column(
                children: List.generate(steps.length, (index) {
                  bool isCompleted = index <= currentStepIndex;
                  bool isLast = index == steps.length - 1;
                  Color color = isCompleted ? AppTheme.bronzeGold : Colors.grey.shade300;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            child: Icon(steps[index]['icon'] as IconData, color: Colors.white, size: 20),
                          ),
                          if (!isLast) Container(width: 2, height: 50, color: color),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(steps[index]['label'] as String,
                          style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, 
                          color: isCompleted ? AppTheme.darkPurple : Colors.grey, fontSize: 16)),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 100), // Khoảng trống cho Bottom UI
          ],
        ),
      ),
      
      // --- PHẦN BOTTOM UI: TỰ ĐỘNG CHUYỂN ĐỔI ---
      bottomSheet: _buildBottomUI(context, isWithinTimeLimit),
    );
  }

  Widget _buildBottomUI(BuildContext context, bool isWithinTimeLimit) {
    // TRƯỜNG HỢP 1: Đã có tài xế nhận đơn -> Hiện thông tin tài xế & nút Chat
    if (order.driverId != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (order.driverAvatar != null && order.driverAvatar!.isNotEmpty)
                      ? NetworkImage("${ApiEndpoints.baseUrl}/../${order.driverAvatar}")
                      : null,
                  child: order.driverAvatar == null ? const Icon(Icons.person, size: 30) : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.driverName ?? "Tài xế đối tác", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(order.driverPhone ?? "Đang cập nhật...", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                // Nút Gọi
                _circleIconButton(Icons.call, Colors.green, () => _makePhoneCall(order.driverPhone ?? "")),
                const SizedBox(width: 12),
                // Nút Chat
                _circleIconButton(Icons.chat_bubble, AppTheme.darkPurple, () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      orderId: order.id, 
                      receiverName: order.driverName ?? "Tài xế", 
                      receiverId: order.driverId!
                    )
                  ));
                }),
              ],
            ),
          ],
        ),
      );
    }

    // TRƯỜNG HỢP 2: Đơn đang chờ, chưa có tài xế -> Hiện nút Hủy/Hotline
    if (order.status == 'pending') {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWithinTimeLimit)
              SizedBox(
                width: double.infinity, height: 55,
                child: OutlinedButton(
                  onPressed: () => _confirmCancelOrder(context),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  child: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            else
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall("19001234"),
                  icon: const Icon(Icons.call, color: AppTheme.darkPurple),
                  label: const Text("GỌI HOTLINE ĐỂ HỦY"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bronzeGold),
                ),
              ),
            const SizedBox(height: 10),
            Text(isWithinTimeLimit ? "Bạn có thể tự hủy trong 2 phút." : "Quá thời gian tự hủy. Vui lòng gọi hỗ trợ.",
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _circleIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}