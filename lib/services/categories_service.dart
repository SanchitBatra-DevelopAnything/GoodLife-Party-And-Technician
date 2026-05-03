import 'dart:convert';
import 'package:goodlife_party/models/categories_model.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String url =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/onlyCategories.json';

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;

      final List<CategoryModel> categories = [];

      data.forEach((key, value) {
        categories.add(CategoryModel.fromMap(key, value));
      });

      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }
}