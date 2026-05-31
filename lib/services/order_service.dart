import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/order_model.dart';

class OrderService {
  Future<void> placeOrder(
    OrderModel order,
  ) async {
    final url =
        'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/activeOrders/${order.orderedBy}.json';

    final response =
        await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode(
        order.toJson(),
      ),
    );

    if (response.statusCode <
            200 ||
        response.statusCode >=
            300) {
      throw Exception(
        'Failed to place order',
      );
    }
  }
}