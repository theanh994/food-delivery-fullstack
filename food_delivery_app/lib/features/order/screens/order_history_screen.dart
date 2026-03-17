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
    // Sử dụng addPostFrameCallback để tránh lỗi setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<OrderProvider>().fetchMyOrders(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ĐƠN HÀNG CỦA TÔI"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Đang đến"),
              Tab(text: "Lịch sử"),
            ],
            labelColor: AppTheme.bronzeGold,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.bronzeGold,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // Chuyển RefreshIndicator vào trong ListView để nó nhạy hơn
        body: Consumer<OrderProvider>(
          builder: (context, prov, _) {
            if (prov.isLoading && prov.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.bronzeGold));
            }
            
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

  Widget _buildOrderList(List orders) {
    // ĐƯA REFRESH INDICATOR VÀO ĐÂY
    return RefreshIndicator(
      color: AppTheme.bronzeGold,
      backgroundColor: AppTheme.darkPurple,
      onRefresh: _refreshData, // Gọi hàm tải lại dữ liệu
      child: ListView.builder(
        // AlwaysScrollableScrollPhysics: Giúp kéo được ngay cả khi danh sách trống
        physics: const AlwaysScrollableScrollPhysics(), 
        padding: const EdgeInsets.all(16),
        itemCount: orders.isEmpty ? 1 : orders.length,
        itemBuilder: (context, index) {
          if (orders.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey)),
                  Text("Vuốt xuống để cập nhật", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }
}