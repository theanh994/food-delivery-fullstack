import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/driver_order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_noti.dart';
import 'active_order_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});
  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Chốt chặn an toàn: Đợi build xong mới load đơn hàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    Future.microtask(() => context.read<DriverOrderProvider>().fetchAvailableOrders());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DriverOrderProvider>();
    final driverId = context.read<AuthProvider>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ĐƠN HÀNG MỚI"),
        centerTitle: true,
        elevation: 0,
      ),
      // --- THÊM REFRESH INDICATOR ---
      body: RefreshIndicator(
        color: AppTheme.bronzeGold,
        backgroundColor: AppTheme.darkPurple,
        onRefresh: () async => await prov.fetchAvailableOrders(),
        child: prov.availableOrders.isEmpty 
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(), // Ép cho phép cuộn để refresh
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Hiện không có đơn hàng nào quanh đây", style: TextStyle(color: Colors.grey)),
                      Text("Hãy vuốt xuống để cập nhật nhé!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: prov.availableOrders.length,
              itemBuilder: (context, index) {
                final order = prov.availableOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("#ORD-${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${order['final_amount']}đ", style: const TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(order['delivery_address'], style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            // Ép kiểu an toàn để tránh lỗi String vs Int
                            int orderId = int.parse(order['id'].toString());
                            
                            bool ok = await prov.acceptOrder(orderId, driverId);
                            
                            if (!mounted) return; 

                            if (ok) {
                              AppNoti.show(context, "Đã nhận đơn thành công!", type: NotiType.success);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ActiveOrderScreen(order: order)
                              ));
                            } else {
                              AppNoti.show(context, "Đơn hàng này đã có người nhận!", type: NotiType.error);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50), 
                            backgroundColor: AppTheme.bronzeGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text("NHẬN ĐƠN NÀY", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}