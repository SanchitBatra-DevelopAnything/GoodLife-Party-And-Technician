import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goodlife_party/models/login_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../models/executive_delivery_order.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool _isPlacingOrder = false;

  bool get isPlacingOrder => _isPlacingOrder;

  bool executiveOrdersLoading = false;

  String? executiveOrdersError;

  List<ExecutiveDeliveryOrder> executiveOrders = [];

  Future<void> placeOrder({
    required CartProvider cartProvider,
    required bool paymentDone,
    String? paymentScreenshotUrl,
  }) async {
    try {
      _isPlacingOrder = true;

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      final loginContextString = prefs.getString('login_context');

      String username = 'UNKNOWN_USER';
      String area = '';
      String contact = '';
      String deviceToken = '';

      if (loginContextString != null) {
        final loginContext = LoginContext.fromJson(
          jsonDecode(loginContextString),
        );

        username = loginContext.distributorDetails.distributorName;
        area = loginContext.distributorDetails.area;
        contact = loginContext.distributorDetails.contact;
        deviceToken = loginContext.distributorDetails.deviceToken;
      }

      final now = DateTime.now();

      final order = OrderModel(
        orderId: const Uuid().v4(),

        totalPrice: cartProvider.grandTotal,

        area: area,

        contact: contact,

        deviceToken: deviceToken,

        items: cartProvider.itemList
            .map(
              (cartItem) => OrderItemModel(
                name: cartItem.title,

                price: cartItem.price,

                quantity: cartItem.quantity,

                totalPrice: cartItem.totalPrice,

                customizationMessage: cartItem.customizedMessage,
              ),
            )
            .toList(),

        orderDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",

        orderTime:
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",

        orderedBy: username,

        gstAmount: cartProvider.gst,

        freightCharges: cartProvider.freightCharges,

        freightPercentage: 5,

        itemTotal: cartProvider.subtotal,

        status: paymentDone ? "PAYMENT_VERIFICATION" : "PENDING",

        documents: paymentScreenshotUrl != null ? [paymentScreenshotUrl] : [],

        partyClaimedPaymentComplete: paymentDone,
      );

      await _orderService.placeOrder(order);

      cartProvider.clearCart();
    } finally {
      _isPlacingOrder = false;

      notifyListeners();
    }
  }

  Future<void> fetchExecutiveDeliveryOrders(String distributorName) async {
    executiveOrdersLoading = true;
    executiveOrdersError = null;

    notifyListeners();

    print(
      "Fetching executive delivery orders for distributor: $distributorName",
    );

    try {
      executiveOrders = await _orderService.getExecutiveDeliveryOrders(
        distributorName,
      );
    } catch (e) {
      executiveOrdersError = e.toString();
    }

    executiveOrdersLoading = false;

    notifyListeners();
  }
}
