import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class DriverOrderProvider with ChangeNotifier {
  List<dynamic> _availableOrders = [];
  dynamic _currentOrder; // Đơn hàng tài xế đang đi giao
  bool _isLoading = false;

  List<dynamic> get availableOrders => _availableOrders;
  dynamic get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;

  Future<void> fetchAvailableOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/driver/get_available_orders.php"));
      _availableOrders = jsonDecode(res.body)['data'];
    } catch (e) { print(e); }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acceptOrder(int orderId, int driverId) async {
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/driver/accept_order.php"),
      body: jsonEncode({"order_id": orderId, "driver_id": driverId})
    );
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      // Sau khi nhận đơn, gán vào currentOrder để theo dõi
      _currentOrder = _availableOrders.firstWhere((o) => o['id'] == orderId);
      _currentOrder['status'] = 'accepted';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/update_order_status.php"),
      body: jsonEncode({"order_id": orderId, "status": newStatus})
    );
    if (_currentOrder != null) {
      _currentOrder['status'] = newStatus;
      if (newStatus == 'completed') _currentOrder = null; // Giao xong thì xóa đơn hiện tại
      notifyListeners();
    }
  }
}