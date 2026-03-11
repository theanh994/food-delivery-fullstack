class CategoryModel {
  final int id;
  final String name;
  final String? imageUrl;

  CategoryModel({required this.id, required this.name, this.imageUrl});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}