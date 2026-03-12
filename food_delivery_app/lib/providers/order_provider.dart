import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import 'cart_provider.dart';

class OrderProvider with ChangeNotifier {
  bool _isPlacingOrder = false;
  bool get isPlacingOrder => _isPlacingOrder;

  Future<bool> placeOrder({
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
            "unit_price": item.basePrice,
            "item_note": item.note
          }).toList(),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        cart.clearCart();
        return true;
      }
      return false;
    } catch (e) {
      print("Order Error: $e");
      return false;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}