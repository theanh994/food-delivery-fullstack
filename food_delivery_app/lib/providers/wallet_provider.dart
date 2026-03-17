import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double _todayEarning = 0.0;
  double _weekEarning = 0.0;
  List<dynamic> _chartData = [];

  double get todayEarning => _todayEarning;
  double get weekEarning => _weekEarning;
  List<dynamic> get chartData => _chartData;

  Future<void> fetchWallet(int driverId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/driver/get_wallet.php?driver_id=$driverId"));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _balance = double.parse(data['balance'].toString());
        _transactions = data['transactions'];
      }
    } catch (e) { print(e); }
    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchEarningsStats(int driverId) async {
    try {
      final res = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/driver/get_earnings_stats.php?driver_id=$driverId"));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _todayEarning = double.parse(data['today'].toString());
        _weekEarning = double.parse(data['week'].toString());
        _chartData = data['chart'];
        notifyListeners();
      }
    } catch (e) { print(e); }
  }
}