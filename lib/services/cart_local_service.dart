import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalService {
  static const String boxName = 'cart_box';

  Future<String> _getCartKey() async {
  final prefs =
      await SharedPreferences.getInstance();

  final userJson =
      prefs.getString('logged_in_user');

  if (userJson == null || userJson.isEmpty) {
    print('No user found, using guest cart');
    return 'guest_cart';
  }

  final userMap = jsonDecode(userJson);

  final contact =
      userMap['contact']?.toString() ?? '';

  if (contact.isEmpty) {
    print('No contact found, using guest cart');
    return 'guest_cart';
  }

  return 'cart_$contact';
}

  Future<void> saveCart(
    List<Map<String, dynamic>> cartItems,
  ) async {
    final box = await Hive.openBox(boxName);

    final cartKey = await _getCartKey();

    await box.put(
      cartKey,
      jsonEncode(cartItems),
    );
  }

  Future<List<dynamic>> fetchCart() async {
    final box = await Hive.openBox(boxName);

    final cartKey = await _getCartKey();

    final data = box.get(cartKey);

    if (data == null) {
      return [];
    }

    return jsonDecode(data);
  }

  Future<void> clearCart() async {
    final box = await Hive.openBox(boxName);

    final cartKey = await _getCartKey();

    await box.delete(cartKey);
  }
}