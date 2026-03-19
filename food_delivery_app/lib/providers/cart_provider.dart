import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/food_model.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items =[];
  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // ĐÃ SỬA: Khai báo đúng 5 tham số
  void addToCart(FoodModel food, double totalPrice, List<SelectedOption> selections, int quantity, String? note) {
    selections.sort((a, b) => a.groupName.compareTo(b.groupName));
    String optionsKey = selections.map((e) => e.toString()).join('|');
    String uniqueId = "${food.id}|$optionsKey|${note ?? ''}";

    int existingIndex = _items.indexWhere((item) => item.uniqueId == uniqueId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        uniqueId: uniqueId,
        foodId: food.id,
        name: food.name,
        basePrice: food.price,
        totalItemPrice: totalPrice,
        selectedOptions: selections,
        imageUrl: food.imageUrl ?? '',
        quantity: quantity,
        note: note,
      ));
    }
    notifyListeners();
  }

  void incrementQuantity(String uniqueId) {
    int index = _items.indexWhere((item) => item.uniqueId == uniqueId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void updateCartItem(String oldUniqueId, CartItem newItem) {
  // 1. Tìm vị trí món cũ
    int index = _items.indexWhere((item) => item.uniqueId == oldUniqueId);
    
    if (index >= 0) {
      // 2. Xóa món cũ
      _items.removeAt(index);
      
      // 3. Kiểm tra xem món mới sau khi sửa có bị TRÙNG với một món khác đã có trong giỏ không
      int duplicateIndex = _items.indexWhere((item) => item.uniqueId == newItem.uniqueId);
      
      if (duplicateIndex >= 0) {
        // Nếu trùng -> Gộp số lượng vào món đã có
        _items[duplicateIndex].quantity += newItem.quantity;
      } else {
        // Nếu không trùng -> Chèn món mới vào đúng vị trí cũ để giữ thứ tự giỏ hàng
        _items.insert(index, newItem);
      }
      notifyListeners();
    }
  }

  void decrementQuantity(String uniqueId) {
    int index = _items.indexWhere((item) => item.uniqueId == uniqueId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  double _discountAmount = 0.0;
  String? _appliedVoucherCode;

  double get discountAmount => _discountAmount;
  String? get appliedVoucherCode => _appliedVoucherCode;

  // Hàm kiểm tra mã từ Server
  Future<bool> applyVoucher(String code) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/check_voucher.php"),
        body: jsonEncode({
          "code": code,
          "total_amount": subtotal
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        _discountAmount = double.parse(data['discount'].toString());
        _appliedVoucherCode = code;
        notifyListeners();
        return true;
      } else {
        _discountAmount = 0;
        _appliedVoucherCode = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void removeVoucher() {
    _discountAmount = 0;
    _appliedVoucherCode = null;
    notifyListeners();
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + (item.totalItemPrice * item.quantity));
  double get shippingFee => 15000.0;
  double get totalAmount =>  (subtotal + shippingFee) - _discountAmount;

  void clearCart() {
    _items =[];
    notifyListeners();
  }
}