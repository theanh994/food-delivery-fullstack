import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_noti.dart';

import '../../../providers/driver_order_provider.dart';
// import '../../../providers/auth_provider.dart';
import '../../chat/screens/chat_screen.dart'; // Chúng ta sẽ tạo ở Bước 3

// ... (Các phần import giữ nguyên)

class ActiveOrderScreen extends StatefulWidget {
  final dynamic order;
  const ActiveOrderScreen({super.key, required this.order});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  bool _isProcessing = false; // Biến chống bấm nút liên tục

  @override
  Widget build(BuildContext context) {
    final driverProv = context.watch<DriverOrderProvider>();
    
    // Lấy trạng thái mới nhất từ Provider, nếu không có thì lấy từ đơn ban đầu
    String currentStatus = driverProv.currentOrder?['status'] ?? widget.order['status'];
    
    // Debug để kiểm tra trạng thái thực tế
    debugPrint("DEBUG: Trạng thái hiện tại của đơn hàng là: $currentStatus");

    return Scaffold(
      appBar: AppBar(
        title: const Text("GIAO HÀNG HIỆN TẠI"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Phần bản đồ (Giữ nguyên)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAwqyMIjjfAubFD6OvU-I38IphjVvlpLT1enBUKwtLrzEvZ_PnRYoNW_bUq_kHjK4OXhMj6eC7H8-0q7HcQenBIzS7xEhtrtgsFs2nB9Tokf8YnxIfDkK_VPq1eHRTJihqNMeoNWO84W03buhje4KuAniqnxko0SQeu0-wA5qFo3rb69ZHn5QJwuLrXNR8Hfe5jm0JvaiztGeq0a5tUzpneQFFa1kVEwxAh8li1yJ74MBDV87n8xLfR5I8TeFBVHqqX4z7FVcXrdOZY"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // 2. Thẻ thông tin và nút bấm
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(widget.order['customer_name'] ?? "Khách hàng", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Text("Đơn hàng #ORD-${widget.order['id']}"),
                  trailing: _chatButton(context),
                ),
                const Divider(),
                _buildInfoRow(Icons.location_on, "Giao đến", widget.order['delivery_address']),
                const SizedBox(height: 25),
                
                // --- NÚT BẤM CẬP NHẬT TRẠNG THÁI ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isProcessing ? null : () async {
                      setState(() => _isProcessing = true);
                      
                      try {
                        int orderId = int.parse(widget.order['id'].toString());
                        
                        // Logic chuyển trạng thái: accepted -> delivering -> completed
                        if (currentStatus == 'accepted') {
                          debugPrint("Đang chuyển trạng thái sang: delivering");
                          await driverProv.updateStatus(orderId, 'delivering');
                        } else {
                          debugPrint("Đang chuyển trạng thái sang: completed");
                          await driverProv.updateStatus(orderId, 'completed');
                          
                          if (context.mounted) {
                            AppNoti.show(context, "Hoàn thành cuốc xe!", type: NotiType.success);
                            Navigator.pushNamedAndRemoveUntil(context, '/driver_home', (route) => false);
                          }
                        }
                      } catch (e) {
                        debugPrint("Lỗi khi bấm nút: $e");
                      } finally {
                        if (mounted) setState(() => _isProcessing = false);
                      }
                    },
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: AppTheme.bronzeGold)
                      : Text(
                          currentStatus == 'accepted' ? "ĐÃ LẤY HÀNG" : "HOÀN THÀNH ĐƠN HÀNG",
                          style: const TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold, fontSize: 16),
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

  // Widget nút Chat tách riêng để gọn code
  Widget _chatButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chat_bubble, color: AppTheme.darkPurple, size: 30),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatScreen(
            orderId: int.parse(widget.order['id'].toString()), 
            receiverName: widget.order['customer_name'].toString(), 
            receiverId: int.parse(widget.order['customer_id'].toString())
          )
        ));
      },
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
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ))
      ],
    );
  }
}