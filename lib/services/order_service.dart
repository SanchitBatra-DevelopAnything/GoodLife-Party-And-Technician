import 'dart:convert';

import 'package:goodlife_party/models/custom_order_model.dart';
import 'package:goodlife_party/models/executive_delivery_order.dart';
import 'package:http/http.dart'
    as http;

import '../models/order_model.dart';



class OrderService {

  static const String customOrdersUrl =
    'https://getpartyinquiryorders-kind2bfhcq-as.a.run.app';

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


  static const String executiveOrdersUrl =
      'https://getpartyexecutivedeliveryorders-kind2bfhcq-as.a.run.app';

  Future<List<ExecutiveDeliveryOrder>>
      getExecutiveDeliveryOrders(
    String partyName,
  ) async {
    final response = await http.post(
      Uri.parse(executiveOrdersUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'partyName': partyName,
      }),
    );

    if (response.statusCode != 200) {
      print(
        'Failed to fetch executive delivery orders. Status code: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception(
        'Unable to fetch executive delivery orders',
      );
    }

    final json =
        jsonDecode(response.body);

    final orders =
        json['orders'] as List<dynamic>? ?? [];

    print("Fetched ${orders.length} executive delivery orders for party: $partyName");

    return orders
        .map(
          (e) =>
              ExecutiveDeliveryOrder.fromJson(
                e,
              ),
        )
        .toList();
  }

  Future<void> placeInquiryOrder(
  CustomOrderModel order,
) async {
  final url =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/inquiryOrders/${order.orderedBy}.json';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(order.toJson()),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'Failed to place inquiry order',
    );
  }
}

Future<List<CustomOrderModel>>
    getInquiryOrders(
  String partyName,
) async {
  final response = await http.post(
    Uri.parse(customOrdersUrl),
    headers: {
      'Content-Type':
          'application/json',
    },
    body: jsonEncode({
      'partyName': partyName,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Unable to fetch custom orders',
    );
  }

  final json =
      jsonDecode(response.body);

  final orders =
      json['orders']
          as List<dynamic>? ??
      [];

  return orders
      .map(
        (e) =>
            CustomOrderModel.fromJson(
          e,
        ),
      )
      .toList();
}

Future<void> updatePurchaseOrder({
  required String firebaseOrderId,
  required String partyName,
  required String poLink,
}) async {
  final url =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/'
      'inquiryOrders/$partyName/$firebaseOrderId.json';

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'poLink': poLink,
      'orderStatus': 'PAYMENT_VERIFICATION',
    }),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'Failed to update purchase order',
    );
  }
}

Future<void> updatePaymentLink({
  required String firebaseOrderId,
  required String partyName,
  required String paymentLink,
}) async {
  final url =
      'https://goodlifeadminapp-default-rtdb.asia-southeast1.firebasedatabase.app/'
      'inquiryOrders/$partyName/$firebaseOrderId.json';

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'paymentLink': paymentLink,
      'orderStatus': 'PAYMENT_VERIFICATION',
    }),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'Failed to update payment link',
    );
  }
}


}