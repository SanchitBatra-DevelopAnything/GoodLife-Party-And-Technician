import 'package:flutter/material.dart';
import 'package:goodlife_party/models/categories_model.dart';
import 'package:goodlife_party/services/categories_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];

  bool isLoading = false;

  List<CategoryModel> get categories => _filteredCategories;


  //null from InventoryPage , emptyList can come from Categories Page , categoriesPage can also send machineIds for filtering
  Future<void> fetchCategories({
  List<String>? machineIds,
}) async {
  isLoading = true;
  notifyListeners();

  try {
    final categories = await _service.fetchCategories();

    if (machineIds == null) {

      // Inventory screen
      // No filtering requested
      _allCategories = categories;

    } else if (machineIds.isEmpty) {

      // User has access to nothing
      _allCategories = [];

    } else {

      _allCategories = categories
          .where((category) => machineIds.contains(category.id))
          .toList();
    }

    _filteredCategories = List.from(_allCategories);

  } catch (e) {
    debugPrint(e.toString());
  }

  isLoading = false;
  notifyListeners();
}

  void search(String query) {
    if (query.trim().isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final searchText = query.toLowerCase();

      _filteredCategories = _allCategories.where((category) {
        return category.name
            .toLowerCase()
            .contains(searchText);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _filteredCategories = List.from(_allCategories);
    notifyListeners();
  }
}