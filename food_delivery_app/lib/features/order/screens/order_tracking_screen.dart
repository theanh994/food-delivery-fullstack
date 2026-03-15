import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã hủy đơn hàng")));
                  Navigator.pop(context); // Quay về trang lịch sử
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
    // Danh sách các mốc trạng thái
    final steps = [
      {'status': 'pending', 'label': 'Đã xác nhận', 'icon': Icons.check_circle},
      {'status': 'accepted', 'label': 'Đang chuẩn bị', 'icon': Icons.restaurant},
      {'status': 'delivering', 'label': 'Đang giao hàng', 'icon': Icons.moped},
      {'status': 'completed', 'label': 'Giao thành công', 'icon': Icons.flag},
    ];

    int currentStepIndex = steps.indexWhere((s) => s['status'] == order.status);
    if (order.status == 'picking') currentStepIndex = 1; // Map 'picking' vào bước chuẩn bị

    return Scaffold(
    backgroundColor: AppTheme.ivoryWhite,
    appBar: AppBar(
      title: const Text("Theo dõi đơn hàng"),
      elevation: 0,
    ),
    body: SingleChildScrollView( // Dùng SingleChildScrollView để nội dung co giãn tự nhiên
      child: Column(
        children: [
          // 1. Phần Bản đồ
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
          
          // 2. PHẦN TIMELINE (Bỏ Expanded, dùng Padding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Column( // Dùng Column thay vì ListView bên trong ScrollView
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
                        if (!isLast) 
                          Container(width: 2, height: 50, color: color), // Đường kẻ dọc
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
          const SizedBox(height: 20), // Khoảng đệm nhỏ cuối danh sách
        ],
      ),
    ),
    
    // 3. ĐƯA NÚT VÀO ĐÂY ĐỂ NÓ LUÔN NẰM DƯỚI CÙNG VÀ ĐẸP MẮT
    bottomNavigationBar: order.status == 'pending' 
      ? SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () => _confirmCancelOrder(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "HỦY ĐƠN HÀNG", 
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)
                ),
              ),
            ),
          ),
        )
      : const SizedBox.shrink(), // Nếu không phải pending thì không hiện gì cả
  );
  }
}