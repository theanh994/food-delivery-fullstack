import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/food_model.dart';

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

  double get subtotal => _items.fold(0, (sum, item) => sum + (item.totalItemPrice * item.quantity));
  double get shippingFee => 15000.0;
  double get totalAmount => subtotal + shippingFee;

  void clearCart() {
    _items =[];
    notifyListeners();
  }
}