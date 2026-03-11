import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

import 'providers/auth_provider.dart'; 
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'features/customer/screens/cart_screen.dart';

import 'features/auth/splash_screen.dart'; 
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart'; 
import 'features/customer/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        // Đã khai báo AuthProvider chuẩn
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
        ChangeNotifierProvider(create: (_) => FoodProvider()), 
        ChangeNotifierProvider(create: (_) => CartProvider()), 
        ChangeNotifierProvider(create: (_) => OrderProvider()), 
      ],
      child: MaterialApp(
        title: 'Đặt Đồ Ăn Single-Vendor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(), // Trỏ về màn hình thật
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),   // Trỏ về màn hình thật
          '/customer_home': (context) => const CustomerHomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/driver_home': (context) => const PlaceholderScreen(title: 'Trang chủ Tài xế'),
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Màn hình $title')),
    );
  }
}