import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class UserAddress {
  final int id;
  final String title;
  final String detail;
  final bool isDefault;

  UserAddress({required this.id, required this.title, required this.detail, this.isDefault = false});
}

class AddressProvider with ChangeNotifier {
  List<dynamic> _addresses = [];
  bool _isLoading = false;

  List<dynamic> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/address_api.php?user_id=$userId"));
      final data = jsonDecode(res.body);
      if(data['status'] == 'success') _addresses = data['data'];
    } catch (e) { debugPrint(e.toString()); }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAddress(int userId, String title, String detail) async {
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/address_api.php"),
      body: jsonEncode({"user_id": userId, "title": title, "address_detail": detail})
    );
    if(jsonDecode(res.body)['status'] == 'success') {
      fetchAddresses(userId);
      return true;
    }
    return false;
  }

  Future<void> deleteAddress(int addressId, int userId) async {
    await http.delete(Uri.parse("${ApiEndpoints.baseUrl}/address_api.php?id=$addressId"));
    fetchAddresses(userId);
  }
}