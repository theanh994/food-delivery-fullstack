import 'food_options.dart';

class FoodModel {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String foodType; // 'drink' hoặc 'food'
  final List<OptionGroup> optionGroups;

  FoodModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.foodType,

    this.imageUrl,
    this.optionGroups = const [],
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: int.parse(json['id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      foodType: json['food_type'] ?? 'food',
      name: json['name'],
      description: json['description'] ?? "",
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      optionGroups: json['option_groups'] != null 
        ? (json['option_groups'] as List).map((g) => OptionGroup.fromJson(g)).toList()
        : [],
    );
  }
}