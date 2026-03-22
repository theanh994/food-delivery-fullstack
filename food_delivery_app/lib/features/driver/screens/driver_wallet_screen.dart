import 'dart:convert'; // Thêm để dùng jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; // Thêm để gọi API
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/app_noti.dart';
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
    // Sử dụng trì hoãn để tránh lỗi build logic
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      context.read<WalletProvider>().fetchWallet(currentUser.id);
    }
  }

  // --- HÀM GỬI YÊU CẦU RÚT TIỀN ---
  void _requestWithdrawal(double amount) async {
    if (amount <= 0) {
      AppNoti.show(context, "Số dư không đủ để rút", type: NotiType.error);
      return;
    }

    final driverId = context.read<AuthProvider>().currentUser!.id;
    
    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/driver/request_withdrawal.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driver_id": driverId,
          "amount": amount
        }),
      );

      if (mounted) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          AppNoti.show(context, data['message'], type: NotiType.success);
          Navigator.pop(context); // Đóng Dialog
          // Tải lại dữ liệu ví để cập nhật trạng thái
          context.read<WalletProvider>().fetchWallet(driverId); 
        } else {
          AppNoti.show(context, data['message'], type: NotiType.error);
        }
      }
    } catch (e) {
      if (mounted) AppNoti.show(context, "Lỗi kết nối máy chủ", type: NotiType.error);
    }
  }

  // --- HÀM HIỂN THỊ DIALOG XÁC NHẬN ---
  void _showWithdrawDialog() {
    final balance = context.read<WalletProvider>().balance;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text("Rút toàn bộ tiền?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Bạn muốn gửi yêu cầu rút ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(balance)} về tài khoản ngân hàng?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Hủy", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bronzeGold),
            onPressed: () => _requestWithdrawal(balance),
            child: const Text("Đồng ý rút", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("VÍ THU NHẬP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppTheme.bronzeGold,
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(wallet, currencyFormat),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Lịch sử giao dịch", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {}, 
                    child: const Text("Xem tất cả", style: TextStyle(color: AppTheme.bronzeGold))
                  ),
                ],
              ),
              const SizedBox(height: 10),
              wallet.isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.bronzeGold))
                : _buildTransactionList(wallet, currencyFormat),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1e293b), Color(0xFF0f172a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text("SỐ DƯ KHẢ DỤNG", 
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(fmt.format(wallet.balance), 
            style: const TextStyle(color: AppTheme.bronzeGold, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showWithdrawDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bronzeGold,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
            child: const Text("RÚT TIỀN VỀ TÀI KHOẢN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(WalletProvider wallet, NumberFormat fmt) {
    if (wallet.transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("Chưa có giao dịch nào", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wallet.transactions.length,
      itemBuilder: (context, index) {
        final tx = wallet.transactions[index];
        return _buildTransactionItem(tx, fmt);
      },
    );
  }

  Widget _buildTransactionItem(dynamic tx, NumberFormat fmt) {
    bool isEarning = tx['type'] == 'earning';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05), 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEarning ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle
            ),
            child: Icon(
              isEarning ? Icons.add_circle_outline : Icons.outbox_outlined, 
              color: isEarning ? Colors.greenAccent : Colors.redAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['description'] ?? "Giao dịch", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(tx['created_at'], 
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(
            "${isEarning ? '+' : '-'}${fmt.format(tx['amount'])}",
            style: TextStyle(
              color: isEarning ? Colors.greenAccent : Colors.redAccent, 
              fontWeight: FontWeight.w900,
              fontSize: 15
            ),
          )
        ],
      ),
    );
  }
}