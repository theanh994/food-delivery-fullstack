import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted':
      case 'picking': return Colors.blue;
      case 'delivering': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return "Đang chờ";
      case 'accepted': return "Đã nhận đơn";
      case 'picking': return "Đang lấy hàng";
      case 'delivering': return "Đang giao";
      case 'completed': return "Đã giao";
      case 'cancelled': return "Đã hủy";
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#EPC-${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(order.status).withValues(alpha: 0.3)),
                  ),
                  child: Text(_getStatusText(order.status), 
                    style: TextStyle(color: _getStatusColor(order.status), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${order.details.length} món", style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(currencyFormat.format(order.finalAmount), 
                  style: const TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}