import 'package:flutter/material.dart';

class AppTheme {
  // 1. Định nghĩa Palette Màu sắc cốt lõi
  static const Color darkPurple = Color(0xFF2D142C); // Tím thẫm (Màu chủ đạo)
  static const Color bronzeGold = Color(0xFFC5A059); // Vàng đồng (Màu nhấn/Action)
  static const Color ivoryWhite = Color(0xFFFAF9F6); // Trắng ngà (Màu nền)
  static const Color textDark = Color(0xFF1A1A1A);   // Màu chữ đen cho dễ đọc
  static const Color textLight = Color(0xFFFFFFFF);  // Màu chữ trắng

  // 2. Cấu hình Theme chính
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: darkPurple,
      scaffoldBackgroundColor: ivoryWhite,
      colorScheme: const ColorScheme.light(
        primary: darkPurple,
        secondary: bronzeGold,
        surface: ivoryWhite,
        onPrimary: textLight,
        onSecondary: textDark,
      ),
      
      // Cấu hình AppBar chung
      appBarTheme: const AppBarTheme(
        backgroundColor: darkPurple,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: bronzeGold),
        titleTextStyle: TextStyle(
          color: bronzeGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),

      // Cấu hình Nút bấm (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bronzeGold,
          foregroundColor: darkPurple, // Màu chữ trên nút
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      // Cấu hình Text chung
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textDark, fontSize: 16),
        bodyMedium: TextStyle(color: textDark, fontSize: 14),
        titleLarge: TextStyle(color: darkPurple, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}