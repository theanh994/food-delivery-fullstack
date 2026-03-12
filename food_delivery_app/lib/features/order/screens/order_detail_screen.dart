import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'delivering': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: Text("Đơn hàng #${order.id}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trạng thái đơn hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _getStatusColor(order.status)),
                  const SizedBox(width: 12),
                  Text("Trạng thái: ${order.status.toUpperCase()}", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(order.status))),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text("Địa chỉ giao hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(order.address, style: const TextStyle(color: Colors.grey)),
            
            const Divider(height: 40),

            const Text("Chi tiết món ăn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            
            // Danh sách món
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.details.length,
              itemBuilder: (context, index) {
                final item = order.details[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${item.quantity}x ${item.foodName}", style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (item.itemNote != null)
                              Text(item.itemNote!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      Text(currencyFormat.format(item.unitPrice * item.quantity)),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 40),

            // Tổng tiền
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Tạm tính"), 
              Text(currencyFormat.format(order.totalAmount))
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Phí giao hàng"), 
              Text(currencyFormat.format(order.shippingFee))
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("TỔNG CỘNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(currencyFormat.format(order.finalAmount), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkPurple)),
            ]),

            const SizedBox(height: 50),

            // Nút Hủy đơn (Chỉ hiện khi đơn là pending)
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    // Lấy userId từ AuthProvider
                    final userId = context.read<AuthProvider>().currentUser!.id;
                    
                    // Truyền cả orderId và userId vào hàm cancel
                    bool ok = await context.read<OrderProvider>().cancelOrder(order.id, userId);
                    
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đã hủy đơn hàng thành công"), backgroundColor: Colors.orange),
                      );
                      Navigator.pop(context); // Quay lại trang lịch sử
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, 
                    side: const BorderSide(color: Colors.red)
                  ),
                  child: const Text("HỦY ĐƠN HÀNG"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}