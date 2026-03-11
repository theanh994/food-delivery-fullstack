import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      print("Lỗi Exception: $e");
      _errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra XAMPP hoặc mạng!';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
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
          "role": "customer" // Mặc định là khách hàng
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
}