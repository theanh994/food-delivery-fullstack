import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallet_provider.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});
  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final driverId = context.read<AuthProvider>().currentUser!.id;
        context.read<WalletProvider>().fetchWallet(driverId);
      }
    });
  }

  void _loadData() {
    // Đảm bảo user đã đăng nhập trước khi lấy ID
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      context.read<WalletProvider>().fetchWallet(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Deep Dark từ HTML
      appBar: AppBar(
        title: const Text("VÍ THU NHẬP"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Thêm dòng này để ẩn nút Back khi ở trong Tab
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARD SỐ DƯ (Gradients) ---
              _buildBalanceCard(wallet, currencyFormat),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Lịch sử giao dịch", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("Xem tất cả", style: TextStyle(color: AppTheme.bronzeGold))),
                ],
              ),

              // --- DANH SÁCH GIAO DỊCH ---
              wallet.isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.bronzeGold))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wallet.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = wallet.transactions[index];
                      return _buildTransactionItem(tx, currencyFormat);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletProvider wallet, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1e293b), Color(0xFF0f172a)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("SỐ DƯ KHẢ DỤNG", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Text(fmt.format(wallet.balance), style: const TextStyle(color: AppTheme.bronzeGold, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showWithdrawDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bronzeGold,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("RÚT TIỀN VỀ TÀI KHOẢN", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic tx, NumberFormat fmt) {
    bool isEarning = tx['type'] == 'earning';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(isEarning ? Icons.add_circle : Icons.remove_circle, color: isEarning ? AppTheme.bronzeGold : Colors.redAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['description'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(tx['created_at'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(
            "${isEarning ? '+' : '-'}${fmt.format(tx['amount'])}",
            style: TextStyle(color: isEarning ? AppTheme.bronzeGold : Colors.redAccent, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text("Yêu cầu rút tiền", style: TextStyle(color: Colors.white)),
        content: const Text("Yêu cầu rút tiền của bạn đã được gửi đến Admin. Tiền sẽ về tài khoản sau 24h làm việc.", style: TextStyle(color: Colors.white70)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng", style: TextStyle(color: AppTheme.bronzeGold)))],
      ),
    );
  }
}