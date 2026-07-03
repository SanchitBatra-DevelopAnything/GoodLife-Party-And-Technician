class ExecutiveDeliveryItem {
  final String name;
  final int quantity;
  final double price;
  final double totalPrice;
  final String customizationMessage;

  ExecutiveDeliveryItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.customizationMessage,
  });

  factory ExecutiveDeliveryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExecutiveDeliveryItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      customizationMessage:
          json['customizationMessage'] ?? '',
    );
  }
}

class ExecutiveDeliveryOrder {
  final String orderId;
  final String orderDate;
  final String orderTime;
  final String orderedBy;
  final String contact;
  final String area;
  final String status;

  final double itemTotal;
  final double freightCharges;
  final double gstAmount;
  final double totalPrice;

  final bool partyClaimedPaymentComplete;

  final String? dispatchedOn;

  final List<String> documents;

  final List<ExecutiveDeliveryItem> items;

  ExecutiveDeliveryOrder({
    required this.orderId,
    required this.orderDate,
    required this.orderTime,
    required this.orderedBy,
    required this.contact,
    required this.area,
    required this.status,
    required this.itemTotal,
    required this.freightCharges,
    required this.gstAmount,
    required this.totalPrice,
    required this.partyClaimedPaymentComplete,
    required this.dispatchedOn,
    required this.documents,
    required this.items,
  });

  factory ExecutiveDeliveryOrder.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExecutiveDeliveryOrder(
      orderId: json['orderId'] ?? '',
      orderDate: json['orderDate'] ?? '',
      orderTime: json['orderTime'] ?? '',
      orderedBy: json['orderedBy'] ?? '',
      contact: json['contact'] ?? '',
      area: json['area'] ?? '',
      status: json['status'] ?? '',
      itemTotal:
          (json['itemTotal'] ?? 0).toDouble(),
      freightCharges:
          (json['FreightCharges'] ?? 0).toDouble(),
      gstAmount:
          (json['GSTAmount'] ?? 0).toDouble(),
      totalPrice:
          (json['totalPrice'] ?? 0).toDouble(),
      partyClaimedPaymentComplete:
          json['partyClaimedPaymentComplete'] ??
              false,
      dispatchedOn: json['dispatchedOn'],
      documents:
          List<String>.from(
            json['documents'] ?? [],
          ),
      items:
          (json['items'] as List<dynamic>? ?? [])
              .map(
                (e) =>
                    ExecutiveDeliveryItem.fromJson(
                      e,
                    ),
              )
              .toList(),
    );
  }
}