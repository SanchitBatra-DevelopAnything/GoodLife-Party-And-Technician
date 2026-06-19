import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:goodlife_party/models/custom_order_model.dart';
import 'package:goodlife_party/models/login_context.dart';
import 'package:goodlife_party/services/storage_service.dart';
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

  List<CustomOrderModel> customOrders = [];

bool customOrdersLoading = false;

String? customOrdersError;


  final StorageService _storageService =
    StorageService();

String _inquiryProgressMessage = '';

String get inquiryProgressMessage =>
    _inquiryProgressMessage;


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


Future<void> placeInquiryOrder({
  required List<File> images,
  required String? message,
}) async {
  try {
    _isPlacingOrder = true;

    _inquiryProgressMessage =
        'Preparing inquiry...';

    notifyListeners();

    final prefs =
        await SharedPreferences.getInstance();

    final loginContextString =
        prefs.getString('login_context');

    String username = 'UNKNOWN_USER';
    String area = '';
    String contact = '';
    String deviceToken = '';

    if (loginContextString != null) {
      final loginContext = LoginContext.fromJson(
        jsonDecode(loginContextString),
      );

      username =
          loginContext
              .distributorDetails
              .distributorName;

      area =
          loginContext
              .distributorDetails
              .area;

      contact =
          loginContext
              .distributorDetails
              .contact;

      deviceToken =
          loginContext
              .distributorDetails
              .deviceToken;
    }

    final List<String> photoUrls = [];

    for (int i = 0; i < images.length; i++) {
      _inquiryProgressMessage =
          'Uploading photo ${i + 1} of ${images.length}';

      notifyListeners();

      final imageUrl =
          await _storageService.uploadCustomOrderImageWithProgress(
        images[i],
        (progress) {},
      );

      photoUrls.add(imageUrl);
    }

    _inquiryProgressMessage =
        'Creating inquiry order...';

    notifyListeners();

    final now = DateTime.now();

    final customOrder = CustomOrderModel(
      area: area,
      orderedBy: username,
      deviceToken: deviceToken,
      contact: contact,

      orderDate:
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",

      orderTime:
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",

      requestedItems: photoUrls,

      requestedMessage:
          message?.trim().isEmpty == true
              ? null
              : message?.trim(),

      orderStatus:
          "INQUIRY",

      piLink: null,

      paymentLink: null,
      firebaseOrderId: null,
    );

    await _orderService.placeInquiryOrder(
      customOrder,
    );

    _inquiryProgressMessage =
        'Inquiry submitted successfully';

    notifyListeners();
  } catch (e) {
    _inquiryProgressMessage =
        'Failed to submit inquiry';

    notifyListeners();

    rethrow;
  } finally {
    _isPlacingOrder = false;

    notifyListeners();
  }
}

Future<void> fetchInquiryOrders(
  String distributorName,
) async {
  customOrdersLoading = true;

  customOrdersError = null;

  notifyListeners();

  try {
    customOrders = await _orderService
        .getInquiryOrders(
      distributorName,
    );
  } catch (e) {
    customOrdersError = e.toString();
  }

  customOrdersLoading = false;

  notifyListeners();
}

Future<void> attachPurchaseOrder({
  required String firebaseOrderId,
  required String partyName,
  required Uint8List pdfBytes,
  required String fileName,
}) async {
  try {
    _isPlacingOrder = true;

    notifyListeners();

    final poLink =
        await _storageService.uploadPurchaseOrder(
      firebaseOrderId: firebaseOrderId,
      pdfBytes: pdfBytes,
      fileName: fileName,
    );

    await _orderService.updatePurchaseOrder(
      firebaseOrderId: firebaseOrderId,
      partyName: partyName,
      poLink: poLink,
    );
  } finally {
    _isPlacingOrder = false;

    notifyListeners();
  }
}

}
