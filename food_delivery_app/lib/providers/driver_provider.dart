import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class DriverProvider with ChangeNotifier {
  String _status = 'unverified'; // unverified, pending, approved
  bool _isLoading = false;

  String get status => _status;
  bool get isLoading => _isLoading;

  Future<void> checkDriverStatus(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/driver/check_status.php?user_id=$userId"));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _status = data['driver_status'];
      }
    } catch (e) { debugPrint(e.toString()); }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitProfile({
    required int userId,
    required String type,
    required String plate,
    required File license,
    required File portrait, // Thêm chân dung
  }) async {
    _isLoading = true;
    notifyListeners();

    var request = http.MultipartRequest('POST', Uri.parse("${ApiEndpoints.baseUrl}/driver/submit_profile.php"));
    request.fields['user_id'] = userId.toString();
    request.fields['vehicle_type'] = type;
    request.fields['vehicle_plate'] = plate;
    
    // Thêm 2 file vào request
    request.files.add(await http.MultipartFile.fromPath('license_image', license.path));
    request.files.add(await http.MultipartFile.fromPath('portrait_image', portrait.path));

    final response = await request.send();
    _isLoading = false;
    
    if (response.statusCode == 200) {
      _status = 'pending';
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}