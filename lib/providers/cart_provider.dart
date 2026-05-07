import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goodlife_party/services/cart_local_service.dart';

class CartItem {
  final String id;
  final String title;
  final String customizedMessage;
  final num quantity;
  final num price;
  final String imageUrl;
  final String parentCategoryType;
  final num totalPrice;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.parentCategoryType,
    required this.quantity,
    required this.totalPrice,
    required this.customizedMessage,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customizedMessage': customizedMessage,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'parentCategoryType': parentCategoryType,
      'totalPrice': totalPrice,
    };
  }
}

class CartProvider with ChangeNotifier {
  final CartLocalService _localService =
      CartLocalService();

  final Map<String, CartItem> _items = {};

  List<CartItem> _itemList = [];

  Timer? _saveDebounce;

  Map<String, CartItem> get items {
    return {..._items};
  }

  List<CartItem> get itemList {
    return [..._itemList];
  }

  int get itemCount {
    return _items.length;
  }

  bool checkInCart(String itemId) {
    return _items.containsKey(itemId);
  }

  num getQuantity(String itemId) {
    return _items[itemId]?.quantity ?? 0;
  }

  num getTotalOrderPrice() {
    double totalPrice = 0;

    for (final item in _itemList) {
      totalPrice += item.totalPrice;
    }

    return totalPrice;
  }

  Future<void> loadLocalCart() async {
    final cartData =
        await _localService.fetchCart();

    _items.clear();

    for (final item in cartData) {
      _items[item['id']] = CartItem(
        id: item['id'],
        title: item['title'],
        customizedMessage:
            item['customizedMessage'] ?? '',
        quantity: item['quantity'],
        price: item['price'],
        imageUrl: item['imageUrl'],
        parentCategoryType:
            item['parentCategoryType'],
        totalPrice: item['totalPrice'],
      );
    }

    formCartList();

    notifyListeners();
  }

  void addItem(
    String itemId,
    num price,
    num quantity,
    String title,
    String imgPath,
    String parentCategory,
    String customizedMessage,
  ) {
    debugPrint(
      "REQUEST TO ADD $title with quantity $quantity",
    );

    if (_items.containsKey(itemId)) {
      final existingItem = _items[itemId]!;

      _items.update(
        itemId,
        (existingCartItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          imageUrl: existingItem.imageUrl,
          parentCategoryType:
              existingItem.parentCategoryType,
          quantity: quantity,
          totalPrice:
              existingItem.price * quantity,
          customizedMessage:
              existingItem.customizedMessage,
          price: existingItem.price,
        ),
      );
    } else {
      _items[itemId] = CartItem(
        id: itemId,
        title: title,
        imageUrl: imgPath,
        parentCategoryType: parentCategory,
        quantity: quantity,
        totalPrice: price * quantity,
        customizedMessage: customizedMessage,
        price: price,
      );
    }

    formCartList();

    _scheduleSave();

    notifyListeners();
  }

  void removeItem(String itemId) {
    if (checkInCart(itemId)) {
      _items.remove(itemId);

      formCartList();

      _scheduleSave();

      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();

    _itemList = [];

    _scheduleSave();

    notifyListeners();
  }

  void formCartList() {
    _itemList = _items.values.toList();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();

    _saveDebounce = Timer(
      const Duration(milliseconds: 300),
      () async {
        await _saveCartLocally();
      },
    );
  }

  Future<void> _saveCartLocally() async {
    await _localService.saveCart(
      itemList
          .map((item) => item.toJson())
          .toList(),
    );
  }
}