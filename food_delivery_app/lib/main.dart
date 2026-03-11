import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider bọc ngoài cùng để cung cấp State cho toàn app
    return MultiProvider(
      providers:[
        // Tạm thời để trống, sau này sẽ thêm AuthProvider, CartProvider...
        Provider(create: (_) => ()), 
      ],
      child: MaterialApp(
        title: 'Đặt Đồ Ăn Single-Vendor',
        debugShowCheckedModeBanner: false, // Ẩn chữ debug
        theme: AppTheme.lightTheme,
        
        // Setup Router cơ bản
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const PlaceholderScreen(title: 'Splash Screen'),
          '/login': (context) => const PlaceholderScreen(title: 'Đăng nhập'),
          '/customer_home': (context) => const PlaceholderScreen(title: 'Trang chủ Khách'),
          '/driver_home': (context) => const PlaceholderScreen(title: 'Trang chủ Tài xế'),
        },
      ),
    );
  }
}

// Widget tạm để test Router, sau này sẽ thay bằng màn hình thật
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Nút test ($title)'),
        ),
      ),
    );
  }
}