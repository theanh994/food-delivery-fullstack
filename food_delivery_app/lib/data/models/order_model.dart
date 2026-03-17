class OrderDetailModel {
  final int foodId;
  final String foodName;
  final int quantity;
  final double unitPrice;
  final String? itemNote;

  OrderDetailModel({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unitPrice,
    this.itemNote,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      foodId: int.parse(json['food_id'].toString()),
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
  final int? driverId; // Thêm trường này
  final String? driverName;
  final String? driverPhone;
  final String? driverAvatar;
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
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverAvatar,
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
      driverId: json['driver_id'] != null ? int.parse(json['driver_id'].toString()) : null,
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverAvatar: json['driver_avatar'],
      details: (json['details'] as List)
          .map((d) => OrderDetailModel.fromJson(d))
          .toList(),
    );
  }
}