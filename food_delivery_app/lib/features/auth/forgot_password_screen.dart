import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _handleForgot() async {
    final result = await context.read<AuthProvider>().forgotPassword(_emailController.text.trim());
    
    if (mounted) {
      if (result['status'] == 'success') {
        // Hiện mã OTP giả lập từ API trả về
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Xác thực OTP (Test)"),
            content: Text("${result['message']}\nMã OTP của bạn là: ${result['otp']}"),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: BackButton(color: AppTheme.darkPurple)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 100, color: AppTheme.bronzeGold),
            const SizedBox(height: 40),
            const Text("Quên mật khẩu?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
            const SizedBox(height: 10),
            const Text("Vui lòng nhập email của bạn để nhận mã xác thực OTP.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "EMAIL",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleForgot,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple),
                child: const Text("GỬI MÃ XÁC NHẬN", style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}