import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/food_model.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get totalItems => _items.length;

  double get subtotal => _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));
  
  double get shippingFee => 15000.0;
  
  double get totalAmount => subtotal + shippingFee;

  void addToCart(FoodModel food, {int quantity = 1, String? note}) {
    if (_items.containsKey(food.id)) {
      _items.update(food.id, (existing) => CartItem(
        foodId: existing.foodId,
        name: existing.name,
        price: existing.price,
        imageUrl: existing.imageUrl,
        quantity: existing.quantity + quantity,
        itemNote: note ?? existing.itemNote,
      ));
    } else {
      _items.putIfAbsent(food.id, () => CartItem(
        foodId: food.id,
        name: food.name,
        price: food.price,
        imageUrl: food.imageUrl ?? '',
        quantity: quantity,
        itemNote: note,
      ));
    }
    notifyListeners();
  }

  void incrementQuantity(int foodId) {
    if (_items.containsKey(foodId)) {
      _items[foodId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int foodId) {
    if (_items.containsKey(foodId)) {
      if (_items[foodId]!.quantity > 1) {
        _items[foodId]!.quantity--;
      } else {
        _items.remove(foodId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}