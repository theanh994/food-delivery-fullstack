import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class ChatProvider with ChangeNotifier {
  List<dynamic> _messages = [];
  Timer? _timer;

  List<dynamic> get messages => _messages;

  // Bắt đầu tự động lấy tin nhắn mỗi 3 giây
  void startPolling(int orderId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchMessages(orderId);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<void> fetchMessages(int orderId) async {
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/chat/get_messages.php?order_id=$orderId"));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _messages = data['data'];
        notifyListeners();
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> sendMessage(int orderId, int senderId, String msg) async {
    await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/chat/send_message.php"),
      body: jsonEncode({"order_id": orderId, "sender_id": senderId, "message": msg})
    );
    fetchMessages(orderId);
  }
}