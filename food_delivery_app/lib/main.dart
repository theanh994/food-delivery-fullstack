import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/driver_order_provider.dart';
import 'providers/chat_provider.dart';

import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
// import 'features/customer/screens/home_screen.dart';
import 'features/customer/screens/cart_screen.dart';
import 'features/notification/screens/notification_screen.dart';
import 'features/order/screens/order_history_screen.dart';
  
import 'features/driver/screens/driver_dashboard_screen.dart';
import 'features/driver/screens/driver_pending_screen.dart';
import 'features/driver/screens/driver_registration_screen.dart';

import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/address_book_screen.dart';
import 'features/profile/screens/change_password_screen.dart';
import 'features/profile/screens/support_screen.dart';

import 'features/home/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => DriverOrderProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Đặt Đồ Ăn Single-Vendor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),

          '/profile': (context) => const ProfileScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/address_book': (context) => const AddressBookScreen(),
          '/change_password': (context) => const ChangePasswordScreen(),

          '/customer_home': (context) => const MainScreen(),
          '/cart': (context) => const CartScreen(),
          '/order_history': (context) => const OrderHistoryScreen(),
          '/notifications': (context) => const NotificationScreen(),

          '/driver_home': (context) => const DriverDashboardScreen(),
          '/driver_pending': (context) => const DriverPendingScreen(),
          '/driver_registration': (context) => const DriverRegistrationScreen(),
          '/support': (context) => const SupportScreen(),
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
