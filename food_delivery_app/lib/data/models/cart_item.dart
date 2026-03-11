class CartItem {
  final int foodId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;
  String? itemNote; // Ghi chú riêng cho món (VD: Ít hành)

  CartItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.itemNote,
  });
}