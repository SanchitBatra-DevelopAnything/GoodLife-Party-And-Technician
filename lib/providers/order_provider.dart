import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

class OrderProvider
    with ChangeNotifier {
  final OrderService
      _orderService =
      OrderService();

  bool _isPlacingOrder = false;

  bool get isPlacingOrder =>
      _isPlacingOrder;

  Future<void> placeOrder({
    required CartProvider
        cartProvider,
    required bool
        paymentDone,
    String?
        paymentScreenshotUrl,
  }) async {
    try {
      _isPlacingOrder = true;

      notifyListeners();

      final prefs =
          await SharedPreferences.getInstance();

      final loggedInUser =
          jsonDecode(
                prefs.getString(
                      'logged_in_user',
                    ) ??
                    '{}',
              )
              as Map<String, dynamic>;

      final username =
          loggedInUser['distributorName'] ??
          'UNKNOWN_USER';

      final now =
          DateTime.now();

      final order =
          OrderModel(
        orderId:
            const Uuid().v4(),

        totalPrice:
            cartProvider
                .grandTotal,

        area:
            loggedInUser['area'] ??
            '',

        contact:
            loggedInUser[
                    'contact'] ??
                '',

        deviceToken:
            loggedInUser[
                    'deviceToken'] ??
                'TEMP_DEVICE_TOKEN',

        items: cartProvider
            .itemList
            .map(
              (cartItem) =>
                  OrderItemModel(
                name:
                    cartItem.title,

                price:
                    cartItem.price,

                quantity:
                    cartItem.quantity,

                totalPrice:
                    cartItem
                        .totalPrice,

                customizationMessage:
                    cartItem
                        .customizedMessage,
              ),
            )
            .toList(),

        orderDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",

        orderTime:
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",

        orderedBy:
            username,

        gstAmount:
            cartProvider.gst,

        freightCharges:
            cartProvider
                .freightCharges,

        freightPercentage:
            5,

        itemTotal:
            cartProvider.subtotal,

        status: paymentDone
            ? "PAYMENT_VERIFICATION"
            : "PENDING",

        documents:
            paymentScreenshotUrl !=
                    null
                ? [
                    paymentScreenshotUrl,
                  ]
                : [],

        partyClaimedPaymentComplete:
            paymentDone,
      );

      await _orderService
          .placeOrder(order);

      cartProvider.clearCart();
    } finally {
      _isPlacingOrder = false;

      notifyListeners();
    }
  }
}