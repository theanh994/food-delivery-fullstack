import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

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
      appBar: AppBar(title: const Text("Theo dõi đơn hàng")),
      body: Column(
        children: [
          // Phần Bản đồ giả lập (Image)
          Container(
            height: 200, width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), 
              image: const DecorationImage(image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAwqyMIjjfAubFD6OvU-I38IphjVvlpLT1enBUKwtLrzEvZ_PnRYoNW_bUq_kHjK4OXhMj6eC7H8-0q7HcQenBIzS7xEhtrtgsFs2nB9Tokf8YnxIfDkK_VPq1eHRTJihqNMeoNWO84W03buhje4KuAniqnxko0SQeu0-wA5qFo3rb69ZHn5QJwuLrXNR8Hfe5jm0JvaiztGeq0a5tUzpneQFFa1kVEwxAh8li1yJ74MBDV87n8xLfR5I8TeFBVHqqX4z7FVcXrdOZY"), fit: BoxFit.cover)),
          ),
          
          // PHẦN TIMELINE
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              itemCount: steps.length,
              itemBuilder: (context, index) {
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
                        style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, 
                                         color: isCompleted ? AppTheme.darkPurple : Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}