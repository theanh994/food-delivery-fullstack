import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import '../data/models/order_model.dart';
import 'cart_provider.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isPlacingOrder = false; // Thêm lại biến này cho CartScreen

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;

  List<OrderModel> get ongoingOrders => _orders.where((o) => 
    ['pending', 'accepted', 'picking', 'delivering'].contains(o.status)).toList();

  List<OrderModel> get historyOrders => _orders.where((o) => 
    ['completed', 'cancelled'].contains(o.status)).toList();

  // HÀM ĐẶT HÀNG (Dùng cho CartScreen)
  Future<int?> placeOrder({
    required int customerId,
    required String address,
    required String note,
    required CartProvider cart,
  }) async {
    _isPlacingOrder = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/place_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "customer_id": customerId,
          "total_amount": cart.subtotal,
          "shipping_fee": cart.shippingFee,
          "final_amount": cart.totalAmount,
          "delivery_address": address,
          "order_note": note,
          "items": cart.items.map((item) => {
            "food_id": item.foodId,
            "quantity": item.quantity,
            "unit_price": item.totalItemPrice,
            "item_note": "${item.selectedOptions.map((e) => "${e.groupName}: ${e.selectedItems.join(', ')}").join(' | ')}${item.note != null ? " (Ghi chú: ${item.note})" : ""}"
          }).toList(),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        cart.clearCart();
        return int.parse(data['order_id'].toString());
      }
      return null;
    } catch (e) {
      debugPrint("Order Error: $e");
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  // HÀM LẤY LỊCH SỬ (Dùng cho OrderHistory)
  Future<void> fetchMyOrders(int customerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/get_orders.php?customer_id=$customerId")
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _orders = (data['data'] as List).map((o) => OrderModel.fromJson(o)).toList();
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int orderId, int userId) async { // Thêm userId vào tham số
    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/cancel_order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId}),
      );
      
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Sau khi hủy thành công, gọi lại hàm lấy danh sách đơn với ĐÚNG userId
        await fetchMyOrders(userId); 
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Cancel Error: $e");
      return false;
    }
  }

}