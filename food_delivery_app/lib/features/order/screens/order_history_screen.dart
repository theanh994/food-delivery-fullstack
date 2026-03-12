import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser!.id;
    Future.microtask(() => context.read<OrderProvider>().fetchMyOrders(userId));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đơn hàng của tôi"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Đang đến"),
              Tab(text: "Lịch sử"),
            ],
            labelColor: AppTheme.bronzeGold,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.bronzeGold,
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, prov, _) {
            if (prov.isLoading) return const Center(child: CircularProgressIndicator());
            
            return TabBarView(
              children: [
                _buildOrderList(prov.ongoingOrders),
                _buildOrderList(prov.historyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(orders) {
    if (orders.isEmpty) return const Center(child: Text("Chưa có đơn hàng nào"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }
}