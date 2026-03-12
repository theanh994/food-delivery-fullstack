import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/food_model.dart';

class CartProvider with ChangeNotifier {
  // Chuyển sang dùng List để chứa các item riêng biệt
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  
  double get shippingFee => 15000.0;
  
  double get totalAmount => subtotal + shippingFee;

  void addToCart(FoodModel food, {int quantity = 1, String? note}) {
    // note bây giờ đã là "Size: L, 50% Đá..." nên uniqueId sẽ khác nhau giữa các Size hoặc giữa các ghi chú khác nhau
    String noteKey = note ?? "no-note";
    String uniqueId = "${food.id}-$noteKey";

    // Kiểm tra xem đã có item nào TRÙNG cả ID và TRÙNG cả Ghi chú chưa
    int existingIndex = _items.indexWhere((item) => item.uniqueId == uniqueId);

    if (existingIndex >= 0) {
      // Nếu trùng hoàn toàn -> Chỉ tăng số lượng
      _items[existingIndex].quantity += quantity;
    } else {
      // Nếu khác ghi chú (hoặc món mới) -> Thêm dòng mới vào List
      _items.add(CartItem(
        uniqueId: uniqueId,
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

  // Tăng/Giảm dựa trên uniqueId thay vì foodId
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

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}