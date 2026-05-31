class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String videoUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.videoUrl,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['categoryName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}