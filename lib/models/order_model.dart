import 'order_item_model.dart';

class OrderModel {
  final String orderId;
  final double totalPrice;
  final String area;
  final String contact;
  final String deviceToken;
  final List<OrderItemModel> items;
  final String orderDate;
  final String orderTime;
  final String orderedBy;
  final double gstAmount;
  final double freightCharges;
  final double freightPercentage;
  final double itemTotal;
  final String status;
  final List<String> documents;
  final bool partyClaimedPaymentComplete;

  OrderModel({
    required this.orderId,
    required this.totalPrice,
    required this.area,
    required this.contact,
    required this.deviceToken,
    required this.items,
    required this.orderDate,
    required this.orderTime,
    required this.orderedBy,
    required this.gstAmount,
    required this.freightCharges,
    required this.freightPercentage,
    required this.itemTotal,
    required this.status,
    required this.documents,
    required this.partyClaimedPaymentComplete,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "totalPrice": totalPrice,
      "area": area,
      "contact": contact,
      "deviceToken": deviceToken,
      "items": items
          .map((item) => item.toJson())
          .toList(),
      "orderDate": orderDate,
      "orderTime": orderTime,
      "orderedBy": orderedBy,
      "GSTAmount": gstAmount,
      "FreightCharges": freightCharges,
      "FreightPercentage":
          freightPercentage,
      "itemTotal": itemTotal,
      "status": status,
      "documents": documents,
      "partyClaimedPaymentComplete":
          partyClaimedPaymentComplete,
    };
  }
}