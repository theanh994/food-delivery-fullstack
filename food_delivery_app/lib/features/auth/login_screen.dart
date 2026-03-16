import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_noti.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Khai báo các Controller để lấy dữ liệu từ TextField
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // 2. Hàm xử lý Đăng nhập
  void _handleLogin() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Gọi API thông qua Provider
    bool success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        AppNoti.show(context, "Chào mừng bạn trở lại!", type: NotiType.success);
        
        // Điều hướng dựa trên Role trả về từ API
        final user = authProvider.currentUser!;
  
        if (user.role == 'driver') {
          // NẾU LÀ TÀI XẾ -> Kiểm tra hồ sơ
          final driverProv = context.read<DriverProvider>();
          await driverProv.checkDriverStatus(user.id);
          
          if (mounted) {
            if (driverProv.status == 'approved') {
              Navigator.pushReplacementNamed(context, '/driver_home');
            } else if (driverProv.status == 'pending') {
              Navigator.pushReplacementNamed(context, '/driver_pending');
            } else {
              Navigator.pushReplacementNamed(context, '/driver_registration');
            }
          }
        } else {
          // NẾU LÀ KHÁCH HÀNG
          Navigator.pushReplacementNamed(context, '/customer_home');
        }
      } else {
        // Hiển thị lỗi (Sai mật khẩu, email không tồn tại...)
        AppNoti.show(
          context, 
          authProvider.errorMessage, // Sẽ hiện: "Sai mật khẩu" hoặc "Email không tồn tại"
          type: NotiType.error
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PHẦN TRÊN: HEADER LUXURY (Giống HTML) ---
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.darkPurple, Color(0xFF1a0f21)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.bronzeGold.withValues(alpha: 0.15),
                        border: Border.all(color: AppTheme.bronzeGold.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.restaurant_menu, color: AppTheme.bronzeGold, size: 50),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'EPICURE',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 36, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 4
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Trải nghiệm ẩm thực thượng hạng\nngay tại không gian của bạn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
            
            // --- PHẦN DƯỚI: FORM ĐĂNG NHẬP ---
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chào mừng trở lại', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                  const SizedBox(height: 8),
                  const Text('Vui lòng đăng nhập để tiếp tục hành trình vị giác.', 
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                  const SizedBox(height: 35),

                  // Email Field
                  _buildLabel("Email"),
                  TextField(
                    controller: _emailController,
                    decoration: _inputStyle("your@email.com", Icons.mail_outline),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildLabel("Mật khẩu"),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputStyle("••••••••", Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  
                  // Remember & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppTheme.bronzeGold,
                            onChanged: (val) => setState(() => _rememberMe = val!),
                          ),
                          const Text('Ghi nhớ', style: TextStyle(color: AppTheme.darkPurple)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // KÍCH HOẠT ĐIỀU HƯỚNG TẠI ĐÂY
                          Navigator.pushNamed(context, '/forgot_password');
                        },
                        child: const Text(
                          'Quên mật khẩu?', 
                          style: TextStyle(
                            color: AppTheme.bronzeGold, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Nút Đăng nhập
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: authProvider.isLoading 
                          ? const CircularProgressIndicator(color: AppTheme.bronzeGold)
                          : const Text('Đăng nhập', style: TextStyle(color: AppTheme.bronzeGold, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- NÚT ĐĂNG KÝ (PHẦN BẠN CẦN) ---
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Bạn chưa có tài khoản?", style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () {
                            // Chuyển sang màn hình Đăng ký
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Đăng ký ngay", 
                            style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),

                  // Social Login (UI Only)
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Hoặc tiếp tục với", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialButton("Google", "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png"),
                      _socialButton("Facebook", "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/600px-Facebook_Logo_%282019%29.png"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget bổ trợ cho Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
    );
  }

  // Widget bổ trợ cho Style của TextField
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.bronzeGold, width: 1)),
    );
  }

  // Widget bổ trợ cho nút Social
  Widget _socialButton(String label, String logoUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.network(logoUrl, width: 20, height: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}