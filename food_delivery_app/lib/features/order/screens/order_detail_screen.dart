import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_noti.dart'; // IMPORT THÊM CÔNG CỤ THÔNG BÁO
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import 'review_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  // --- HELPER 1: MÀU SẮC TRẠNG THÁI ---
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'delivering': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  // --- HELPER 2: DIALOG XÁC NHẬN HỦY (ĐÃ CẬP NHẬT APPNOTI) ---
  void _confirmCancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("Đóng")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final userId = context.read<AuthProvider>().currentUser!.id;
              
              // Gọi API hủy đơn thông qua Provider
              bool success = await context.read<OrderProvider>().cancelOrder(order.id, userId);
              
              if (context.mounted) {
                Navigator.pop(dialogContext); // Đóng dialog hỏi
                
                if (success) {
                  // DÙNG THÔNG BÁO SINH ĐỘNG MỚI
                  AppNoti.show(
                    context, 
                    "Đã hủy đơn hàng thành công!", 
                    type: NotiType.success
                  );
                  
                  // Quay lại màn hình lịch sử đơn hàng
                  Navigator.pop(context); 
                } else {
                  // BÁO LỖI NẾU KHÔNG HỦY ĐƯỢC
                  AppNoti.show(
                    context, 
                    "Không thể hủy đơn vào lúc này.", 
                    type: NotiType.error
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
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(title: Text("Đơn hàng #${order.id}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Trạng thái
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _getStatusColor(order.status).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _getStatusColor(order.status)),
                  const SizedBox(width: 12),
                  Text(
                    "TRẠNG THÁI: ${order.status.toUpperCase()}", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(order.status))
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text("Địa chỉ giao hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(order.address, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            
            const Divider(height: 40),

            const Text("Chi tiết món ăn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            
            // Danh sách các món ăn trong đơn
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.details.length,
              itemBuilder: (context, index) {
                final item = order.details[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${item.quantity}x ${item.foodName}", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            if (item.itemNote != null && item.itemNote!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(item.itemNote!, 
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                      ),
                      Text(currencyFormat.format(item.unitPrice * item.quantity), 
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 40),

            // Bảng tính tiền
            _buildPriceRow("Tạm tính", currencyFormat.format(order.totalAmount), false),
            const SizedBox(height: 8),
            _buildPriceRow("Phí giao hàng", currencyFormat.format(order.shippingFee), false),
            const SizedBox(height: 12),
            _buildPriceRow("TỔNG CỘNG", currencyFormat.format(order.finalAmount), true),

            const SizedBox(height: 50),

            // Nút Đánh giá (Chỉ hiện khi hoàn thành)
            if (order.status == 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bronzeGold, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ReviewScreen(
                        orderId: order.id, 
                        foodId: order.details[0].foodId,
                        foodName: order.details[0].foodName
                      )
                    ));
                  },
                  child: const Text("ĐÁNH GIÁ TRẢI NGHIỆM", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

            // Nút Hủy đơn (Chỉ hiện khi đang chờ xác nhận)
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _confirmCancelOrder(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, 
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget dòng giá tiền
  Widget _buildPriceRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
          fontSize: isBold ? 18 : 14,
          color: isBold ? AppTheme.darkPurple : Colors.black54
        )),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
          fontSize: isBold ? 20 : 14, 
          color: isBold ? AppTheme.darkPurple : Colors.black
        )),
      ],
    );
  }
}