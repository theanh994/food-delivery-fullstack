import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import thư viện gọi điện
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_noti.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  // --- HÀM GỌI ĐIỆN HOTLINE ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
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
    // 1. Tính toán thời gian thực tế
    final int secondsPassed = DateTime.now().difference(order.createdAt).inSeconds;
    final bool isWithinTimeLimit = secondsPassed < 120; // 120 giây = 2 phút

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
            // Phần Bản đồ minh họa
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAwqyMIjjfAubFD6OvU-I38IphjVvlpLT1enBUKwtLrzEvZ_PnRYoNW_bUq_kHjK4OXhMj6eC7H8-0q7HcQenBIzS7xEhtrtgsFs2nB9Tokf8YnxIfDkK_VPq1eHRTJihqNMeoNWO84W03buhje4KuAniqnxko0SQeu0-wA5qFo3rb69ZHn5QJwuLrXNR8Hfe5jm0JvaiztGeq0a5tUzpneQFFa1kVEwxAh8li1yJ74MBDV87n8xLfR5I8TeFBVHqqX4z7FVcXrdOZY"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Phần Timeline
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
                        child: Text(
                          steps[index]['label'] as String,
                          style: TextStyle(
                            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, 
                            color: isCompleted ? AppTheme.darkPurple : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      
      // --- PHẦN BOTTOM NAVIGATION BAR: LOGIC NÚT ĐỘNG ---
      bottomNavigationBar: order.status == 'pending' 
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWithinTimeLimit)
                    // NÚT HỦY (Dưới 2 phút)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () => _confirmCancelOrder(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  else
                    // NÚT GỌI HOTLINE (Sau 2 phút)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall("19001234"),
                        icon: const Icon(Icons.call, color: AppTheme.darkPurple),
                        label: const Text("GỌI HOTLINE ĐỂ HỦY", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.bronzeGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 10),
                  Text(
                    isWithinTimeLimit 
                      ? "Bạn có thể tự hủy đơn trong vòng 2 phút." 
                      : "Đã quá thời gian tự hủy. Vui lòng gọi điện để được hỗ trợ.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}