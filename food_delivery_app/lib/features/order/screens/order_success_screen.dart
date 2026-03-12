import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bronzeGold.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.bronzeGold, width: 2),
                ),
                child: const Icon(Icons.card_giftcard, color: AppTheme.bronzeGold, size: 80),
              ),
              const SizedBox(height: 40),
              const Text("Đặt hàng thành công!", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
              const SizedBox(height: 15),
              const Text("Tiệm đang chuẩn bị món cho bạn nhé.\nSẵn sàng để thưởng thức!", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/order_history'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple),
                  child: const Text("Theo dõi đơn hàng", style: TextStyle(color: AppTheme.bronzeGold)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/customer_home'),
                child: const Text("Về trang chủ", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}