import 'dart:convert';

import 'package:goodlife_party/models/item_model.dart';
import 'package:http/http.dart' as http;

class ItemsService {
  Future<List<ItemModel>> fetchItems(String categoryId) async {
    final url = Uri.parse(
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/Categories/$categoryId/items.json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch items');
    }

    final data = json.decode(response.body);

    if (data == null) {
      return [];
    }

    final List<ItemModel> items = [];

    data.forEach((key, value) {
      items.add(ItemModel.fromMap(key, value));
    });

    return items;
  }
}