class OrderDetailModel {
  final String foodName;
  final int quantity;
  final double unitPrice;
  final String? itemNote;

  OrderDetailModel({
    required this.foodName,
    required this.quantity,
    required this.unitPrice,
    this.itemNote,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      foodName: json['food_name'] ?? 'Món ăn',
      quantity: int.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      itemNote: json['item_note'],
    );
  }
}

class OrderModel {
  final int id;
  final double totalAmount;
  final double shippingFee; // Dùng lạc đà (camelCase)
  final double finalAmount;
  final String status;
  final String address;
  final String? note;
  final DateTime createdAt;
  final List<OrderDetailModel> details;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.shippingFee,
    required this.finalAmount,
    required this.status,
    required this.address,
    this.note,
    required this.createdAt,
    required this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: int.parse(json['id'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      shippingFee: double.parse(json['shipping_fee'].toString()), // Khớp với DB
      finalAmount: double.parse(json['final_amount'].toString()),
      status: json['status'],
      address: json['delivery_address'],
      note: json['order_note'],
      createdAt: DateTime.parse(json['created_at']),
      details: (json['details'] as List)
          .map((d) => OrderDetailModel.fromJson(d))
          .toList(),
    );
  }
}