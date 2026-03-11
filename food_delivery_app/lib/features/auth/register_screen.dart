import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Quay lại màn hình Login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Epicure', style: TextStyle(color: AppTheme.darkPurple)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tạo tài khoản', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
              const SizedBox(height: 8),
              const Text('Tham gia cộng đồng Epicure để tận hưởng tinh hoa ẩm thực.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // Họ và tên
              _buildLabel("Họ và tên"),
              TextFormField(
                controller: _nameController,
                decoration: _inputStyle("Nhập họ và tên đầy đủ", Icons.person_outline),
                validator: (val) => val!.isEmpty ? "Vui lòng nhập họ tên" : null,
              ),
              const SizedBox(height: 16),

              // Số điện thoại
              _buildLabel("Số điện thoại"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputStyle("09xx xxx xxx", Icons.phone_android_outlined),
                validator: (val) => val!.length < 10 ? "Số điện thoại không hợp lệ" : null,
              ),
              const SizedBox(height: 16),

              // Email
              _buildLabel("Email"),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("example@epicure.com", Icons.mail_outline),
                validator: (val) => !val!.contains("@") ? "Email không hợp lệ" : null,
              ),
              const SizedBox(height: 16),

              // Mật khẩu
              _buildLabel("Mật khẩu"),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputStyle("••••••••", Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => val!.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
              ),
              const SizedBox(height: 16),

              // Xác nhận mật khẩu
              _buildLabel("Xác nhận mật khẩu"),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputStyle("••••••••", Icons.lock_reset_outlined),
                validator: (val) => val != _passwordController.text ? "Mật khẩu không khớp" : null,
              ),
              const SizedBox(height: 32),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple),
                  child: authProvider.isLoading 
                    ? const CircularProgressIndicator(color: AppTheme.bronzeGold)
                    : const Text('Tạo tài khoản', style: TextStyle(color: AppTheme.bronzeGold, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
  );

  InputDecoration _inputStyle(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
  );
}