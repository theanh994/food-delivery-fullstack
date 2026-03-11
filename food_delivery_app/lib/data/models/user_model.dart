class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'customer', 'driver', 'admin'
  final String? avatar;
  
  // Các trường của Driver
  final bool isDriverApproved;
  final String? vehicleType;
  final String? licensePlate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.isDriverApproved = false,
    this.vehicleType,
    this.licensePlate,
  });

  // Chuyển JSON từ API PHP thành Object Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatar: json['avatar'],
      isDriverApproved: json['is_driver_approved'] == 1 || json['is_driver_approved'] == true,
      vehicleType: json['vehicle_type'],
      licensePlate: json['license_plate'],
    );
  }
}