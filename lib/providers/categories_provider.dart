import 'package:flutter/material.dart';
import 'package:goodlife_party/models/categories_model.dart';
import 'package:goodlife_party/services/categories_service.dart';


class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];

  bool isLoading = false;

  List<CategoryModel> get categories => _filteredCategories;

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      _allCategories = await _service.fetchCategories();
      _filteredCategories = _allCategories;
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredCategories = _allCategories;
    } else {
      _filteredCategories = _allCategories
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}