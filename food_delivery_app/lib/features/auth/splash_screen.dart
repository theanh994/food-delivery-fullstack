import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  // Đã thêm Future<void> để sửa lỗi Missing type annotation
  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Đã thay .withOpacity thành .withValues(alpha: ...)
                border: Border.all(color: AppTheme.bronzeGold.withValues(alpha: 0.2), width: 2),
                color: AppTheme.bronzeGold.withValues(alpha: 0.05),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: AppTheme.bronzeGold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'EPICURE',
              style: TextStyle(
                color: AppTheme.bronzeGold,
                fontSize: 36,
                fontWeight: FontWeight.w300,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'THE ART OF FINE DINING',
              style: TextStyle(
                color: AppTheme.bronzeGold.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.bronzeGold.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.bronzeGold),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'INITIALIZING LUXURY...',
              style: TextStyle(
                color: AppTheme.bronzeGold.withValues(alpha: 0.4),
                fontSize: 10,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}