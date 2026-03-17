import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Thư viện biểu đồ
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallet_provider.dart';
import 'package:intl/intl.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final driverId = context.read<AuthProvider>().currentUser!.id;
      context.read<WalletProvider>().fetchEarningsStats(driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Nền tối Luxury
      appBar: AppBar(
        title: const Text("THỐNG KÊ THU NHẬP", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TỔNG QUAN ---
            Row(
              children: [
                _buildStatCard("Hôm nay", fmt.format(wallet.todayEarning), Colors.greenAccent),
                const SizedBox(width: 15),
                _buildStatCard("7 ngày qua", fmt.format(wallet.weekEarning), AppTheme.bronzeGold),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text("BIỂU ĐỒ DOANH THU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- BIỂU ĐỒ ---
            Container(
              height: 250,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
              child: wallet.chartData.isEmpty 
                ? const Center(child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey)))
                : BarChart(_mainBarData(wallet.chartData)),
            ),

            const SizedBox(height: 30),
            const Text("MẸO TĂNG THU NHẬP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildTipItem(Icons.bolt, "Hoạt động vào giờ cao điểm (11h - 13h) để nhận nhiều đơn hơn."),
            _buildTipItem(Icons.star, "Giữ thái độ thân thiện để nhận đánh giá 5 sao từ khách hàng."),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  BarChartData _mainBarData(List<dynamic> data) {
    return BarChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false), // Ẩn lưới cho đẹp
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Ẩn cột dọc bên trái
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (double value, TitleMeta meta) {
              // --- ĐÃ SỬA TẠI ĐÂY ---
              int index = value.toInt();
              if (index >= 0 && index < data.length) {
                return SideTitleWidget(
                  meta: meta, // Truyền nguyên đối tượng meta vào đây (Sửa lỗi yêu cầu meta)
                  space: 4,
                  child: Text(
                    data[index]['day'].toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      barGroups: List.generate(data.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              // Đảm bảo ép kiểu double như bước trước để tránh crash
              toY: double.parse(data[index]['amount'].toString()), 
              color: AppTheme.bronzeGold,
              width: 15,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            )
          ],
        );
      }),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.bronzeGold, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}