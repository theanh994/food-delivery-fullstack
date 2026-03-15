import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../providers/auth_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Biến dùng để trigger FutureBuilder chạy lại
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Hàm khởi tạo/tải lại dữ liệu
  void _loadNotifications() {
    final userId = context.read<AuthProvider>().currentUser!.id;
    _notificationsFuture = _fetchNotis(userId);
  }

  Future<List<dynamic>> _fetchNotis(int userId) async {
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/get_notifications.php?user_id=$userId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Hàm xử lý khi người dùng vuốt màn hình xuống để tải lại
  Future<void> _onRefresh() async {
    setState(() {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        centerTitle: true,
      ),
      // --- THÊM REFRESH INDICATOR ---
      body: RefreshIndicator(
        onRefresh: _onRefresh, // Gọi hàm này khi vuốt xuống
        color: AppTheme.bronzeGold,
        backgroundColor: AppTheme.darkPurple,
        child: FutureBuilder<List<dynamic>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.bronzeGold));
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView( // Dùng ListView để RefreshIndicator hoạt động được ngay cả khi trống
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text("Không có thông báo mới", style: TextStyle(color: Colors.grey))),
                ],
              );
            }

            final notis = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: notis.length,
              itemBuilder: (context, index) {
                final noti = notis[index];
                bool isUnread = noti['is_read'].toString() == "0";

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUnread ? AppTheme.bronzeGold.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isUnread ? AppTheme.bronzeGold.withValues(alpha: 0.2) : Colors.grey.shade100,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUnread ? AppTheme.bronzeGold : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(noti['title']),
                        color: isUnread ? Colors.white : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      noti['title'],
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(noti['message'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text(
                          noti['created_at'].toString().substring(0, 16),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: isUnread 
                      ? const CircleAvatar(radius: 4, backgroundColor: Colors.red)
                      : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Hàm helper để chọn Icon dựa theo tiêu đề thông báo
  IconData _getIcon(String title) {
    if (title.contains("hủy")) return Icons.cancel_outlined;
    if (title.contains("thành công")) return Icons.check_circle_outline;
    if (title.contains("đang giao")) return Icons.local_shipping_outlined;
    return Icons.notifications_none;
  }
}