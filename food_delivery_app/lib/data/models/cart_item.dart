class SelectedOption {
  final String groupName;
  final List<String> selectedItems; // Lưu tên các item đã chọn trong group

  SelectedOption({required this.groupName, required this.selectedItems});

  @override
  String toString() => "$groupName:${selectedItems.join(',')}";
}

class CartItem {
  final String uniqueId; // Tạo ra từ foodId + itemNote
  final int foodId;
  final String name;
  final double basePrice;
  final double totalItemPrice; // Giá sau khi cộng extra options
  final List<SelectedOption> selectedOptions; // Lưu lựa chọn để hiển thị và tính toán
  final String imageUrl;
  int quantity;
  final String? note; // Ghi chú riêng cho món (VD: Ít hành)

  CartItem({
    required this.uniqueId,
    required this.foodId,
    required this.name,
    required this.basePrice,
    required this.totalItemPrice,
    required this.selectedOptions,
    required this.imageUrl,
    this.quantity = 1,
    required this.note,
  });
}