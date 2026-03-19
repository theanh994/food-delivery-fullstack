import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/models/category_model.dart';
import '../data/models/food_model.dart';
import '../core/constants/api_endpoints.dart';

class FoodProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<FoodModel> _foods = [];
  bool _isLoading = false;
  int _selectedCategoryId = 0; // 0 nghĩa là chọn "Tất cả"

  List<CategoryModel> get categories => _categories;
  List<FoodModel> get foods => _selectedCategoryId == 0 
      ? _foods 
      : _foods.where((f) => f.categoryId == _selectedCategoryId).toList();
  bool get isLoading => _isLoading;
  int get selectedCategoryId => _selectedCategoryId;

  List<FoodModel> _searchResults = [];
  bool _isSearching = false;

  List<FoodModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/search_food.php?query=$query")
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _searchResults = (data['data'] as List).map((f) => FoodModel.fromJson(f)).toList();
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/get_menu.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _categories = (data['categories'] as List).map((c) => CategoryModel.fromJson(c)).toList();
          _foods = (data['foods'] as List).map((f) => FoodModel.fromJson(f)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching menu: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}