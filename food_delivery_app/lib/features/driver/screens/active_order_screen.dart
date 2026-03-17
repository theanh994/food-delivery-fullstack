import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/driver_order_provider.dart';
// import '../../../providers/auth_provider.dart';
import '../../chat/screens/chat_screen.dart'; // Chúng ta sẽ tạo ở Bước 3

class ActiveOrderScreen extends StatelessWidget {
  final dynamic order;
  const ActiveOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final driverProv = context.watch<DriverOrderProvider>();
    final currentStatus = driverProv.currentOrder?['status'] ?? order['status'];

    return Scaffold(
      appBar: AppBar(title: const Text("GIAO HÀNG HIỆN TẠI")),
      body: Column(
        children: [
          // Phần bản đồ giả lập
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCoMiNxry5Z0703PhMs8F1PGx_3Q-xFNe8bYN-jL-2FVpT34dlU9L5q2LLT56wWQNNVHYsGQURiB7U0iezpHPcSxfk3GYd_UOKddMlYzfbrynN12xQW1RZ2wkLa27r4zid5c88AoKKflNJJBUuIehtbvmGpmfExkchCmnok5V3lsdQ0KZhF-DIMU_2bQ7orPjc7JKrvYPIImCoOquXkDL0ZeR8Rf6E0rk3L0vbHxQq4c2RE5Wy-87jpDIqJERp3VoBv27Vnm18E2Rc6"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Thông tin khách hàng & Nút bấm
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(order['customer_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Text("Đơn hàng #ORD-${order['id']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat, color: AppTheme.darkPurple, size: 30),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        orderId: int.parse(order['id'].toString()), 
                        receiverName: order['customer_name'].toString(), 
                        receiverId: int.parse(order['customer_id'].toString())
                      )
                    )),
                  ),
                ),
                const Divider(),
                _buildInfoRow(Icons.location_on, "Giao đến", order['delivery_address']),
                const SizedBox(height: 25),
                
                // NÚT TRẠNG THÁI LINH HOẠT
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple),
                    onPressed: () async {
                      if (currentStatus == 'accepted') {
                        await driverProv.updateStatus(order['id'], 'delivering');
                      } else if (currentStatus == 'delivering') {
                        await driverProv.updateStatus(order['id'], 'completed');
                        Navigator.pop(context); // Hoàn thành thì về Dashboard
                      }
                    },
                    child: Text(
                      currentStatus == 'accepted' ? "ĐÃ LẤY HÀNG" : "HOÀN THÀNH ĐƠN HÀNG",
                      style: const TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.bronzeGold, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ))
      ],
    );
  }
}