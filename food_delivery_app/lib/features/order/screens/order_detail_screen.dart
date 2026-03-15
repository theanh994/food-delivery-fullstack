import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import 'review_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  // --- HÀM HELPER 1: TRẢ VỀ MÀU TRẠNG THÁI ---
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'delivering': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  // --- HÀM HELPER 2: HIỆN DIALOG XÁC NHẬN HỦY (ĐÃ ĐƯA RA NGOÀI HÀM BUILD) ---
  void _confirmCancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Đóng")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final userId = context.read<AuthProvider>().currentUser!.id;
              bool success = await context.read<OrderProvider>().cancelOrder(order.id, userId);
              
              if (context.mounted) {
                Navigator.pop(dialogContext); // Đóng dialog
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã hủy đơn hàng thành công"), backgroundColor: Colors.orange)
                  );
                  Navigator.pop(context); // Quay về màn hình lịch sử
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Không thể hủy đơn vào lúc này"), backgroundColor: Colors.red)
                  );
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
            _buildPriceRow("Tạm tính", currencyFormat.format(order.totalAmount), false),
            const SizedBox(height: 8),
            _buildPriceRow("Phí giao hàng", currencyFormat.format(order.shippingFee), false),
            const SizedBox(height: 12),
            _buildPriceRow("TỔNG CỘNG", currencyFormat.format(order.finalAmount), true),

            const SizedBox(height: 50),

            // Nút Đánh giá (Hiện khi đã hoàn thành)
            if (order.status == 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bronzeGold, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ReviewScreen(
                        orderId: order.id, 
                        foodId: order.details[0].foodId,
                        foodName: order.details[0].foodName
                      )
                    ));
                  },
                  child: const Text("ĐÁNH GIÁ MÓN ĂN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

            // Nút Hủy đơn (Hiện khi đang chờ)
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _confirmCancelOrder(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, 
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget phụ trợ để tránh lặp code hiển thị giá
  Widget _buildPriceRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14, color: isBold ? AppTheme.darkPurple : Colors.black)),
      ],
    );
  }
}