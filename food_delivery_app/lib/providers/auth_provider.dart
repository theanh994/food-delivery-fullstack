import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/models/user_model.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = ''; // Thêm biến lưu lỗi để hiển thị lên UI

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Gọi API PHP
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      // Kiểm tra HTTP Status Code (200 là OK)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Chuyển JSON thành Model
          _currentUser = UserModel.fromJson(data['data']);
          updateFCMToken(_currentUser!.id); 
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Sai mật khẩu hoặc email không tồn tại
          _errorMessage = data['message'] ?? 'Đăng nhập thất bại';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Lỗi máy chủ: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("Lỗi Exception: $e");
      _errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra XAMPP hoặc mạng!';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/forgot_password.php"),
        body: jsonEncode({"email": email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Lỗi kết nối máy chủ"};
    }
  }

  Future<bool> changePassword(int userId, String oldPass, String newPass) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/change_password.php"),
        body: jsonEncode({
          "user_id": userId,
          "old_password": oldPass,
          "new_password": newPass
        }),
      );
      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();
      return data['status'] == 'success';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password, String role) async {
  _isLoading = true;
  _errorMessage = '';
  notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "role": role
        }),
      ).timeout(const Duration(seconds: 10)); // Quá 10 giây sẽ tự ngắt và báo lỗi

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isLoading = false;
        if (data['status'] == 'success') {
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'];
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = "Lỗi máy chủ (${response.statusCode})";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Không thể kết nối API. Kiểm tra XAMPP!";
      notifyListeners();
      return false;
    }
  }
  // Hàm cập nhật thông tin User từ dữ liệu mới (dùng sau khi Edit Profile)
  void updateUser(UserModel newUser) {
    _currentUser = newUser;
    notifyListeners(); // Thông báo để toàn bộ giao diện (Home, Profile) đổi tên ngay
  }
  
  Future<bool> becomeDriver(int userId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/driver/become_driver.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Cập nhật lại user hiện tại với role mới là 'driver'
        _currentUser = UserModel.fromJson(data['data']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = '';
    notifyListeners();
  }

  // ĐỒNG BỘ FCM TOKEN
  Future<void> updateFCMToken(int userId) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Yêu cầu quyền thông báo (Standard for iOS/Android 13+)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Lấy mã định danh duy nhất của thiết bị này
      String? token = await messaging.getToken();

      if (token != null) {
        // 3. Gọi API lưu vào Database
        // Đảm bảo bạn đã tạo file api/update_fcm_token.php
        await http.post(
          Uri.parse("${ApiEndpoints.baseUrl}/update_fcm_token.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId,
            "fcm_token": token
          }),
        );
        debugPrint("FCM Token đã được cập nhật: $token");
      }
    } catch (e) {
      debugPrint("Lỗi khi cập nhật FCM Token: $e");
    }
  }
}