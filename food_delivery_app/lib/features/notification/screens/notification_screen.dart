import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../providers/auth_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<List<dynamic>> _fetchNotis(int userId) async {
    final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/get_notifications.php?user_id=$userId"));
    return jsonDecode(res.body)['data'];
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo")),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchNotis(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("Không có thông báo mới"));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final noti = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.bronzeGold.withValues(alpha: 0.1), child: const Icon(Icons.notifications, color: AppTheme.bronzeGold)),
                title: Text(noti['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(noti['message']),
                trailing: Text(noti['created_at'].toString().substring(11, 16), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                tileColor: noti['is_read'] == "0" ? AppTheme.bronzeGold.withValues(alpha: 0.05) : null,
              );
            },
          );
        },
      ),
    );
  }
}