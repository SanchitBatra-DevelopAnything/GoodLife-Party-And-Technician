import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goodlife_party/models/whats_new_item.dart';
import 'package:http/http.dart' as http;

class WhatsNewProvider extends ChangeNotifier {
  final List<WhatsNewItem> _items = [];

  List<WhatsNewItem> get items => _items;

  Future<void> fetchWhatsNew() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/whatsNew.json',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _items.clear();

        if (data != null && data is Map<String, dynamic>) {
          data.forEach((key, value) {
            _items.add(
              WhatsNewItem.fromJson(value),
            );
          });
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('WhatsNew Error: $e');
    }
  }
}