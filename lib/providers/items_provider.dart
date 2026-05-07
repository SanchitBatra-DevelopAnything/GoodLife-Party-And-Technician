import 'package:flutter/material.dart';
import 'package:goodlife_party/models/item_model.dart';
import 'package:goodlife_party/services/items_service.dart';

class ItemsProvider extends ChangeNotifier {
  final ItemsService _service = ItemsService();

  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];

  bool isLoading = false;

  List<ItemModel> get items => _filteredItems;

  Future<void> fetchItems(String categoryId) async {
    isLoading = true;
    notifyListeners();

    try {
      _allItems = await _service.fetchItems(categoryId);
      _filteredItems = _allItems;
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredItems = _allItems;
    } else {
      _filteredItems = _allItems.where((item) {
        return item.itemName
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }
}