class CustomOrderModel {
  final String area;
  final String orderedBy;
  final String deviceToken;
  final String orderDate;
  final String orderTime;
  final String contact;

  final List<String> requestedItems;
  final String? requestedMessage;

  final String orderStatus;

  final String? piLink;
  final String? paymentLink;
  final String? poLink;

  CustomOrderModel({
    required this.area,
    required this.orderedBy,
    required this.deviceToken,
    required this.orderDate,
    required this.orderTime,
    required this.contact,
    required this.requestedItems,
    this.requestedMessage,
    required this.orderStatus,
    this.piLink,
    this.paymentLink,
    this.poLink
  });

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'orderedBy': orderedBy,
      'deviceToken': deviceToken,
      'orderDate': orderDate,
      'orderTime': orderTime,
      'contact': contact,
      'requestedItems': requestedItems,
      'requestedMessage': requestedMessage,
      'orderStatus': orderStatus,
      'piLink': piLink,
      'paymentLink': paymentLink,
      'poLink': poLink,
    };
  }

  factory CustomOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomOrderModel(
      area: json['area'] ?? '',
      orderedBy: json['orderedBy'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      orderDate: json['orderDate'] ?? '',
      orderTime: json['orderTime'] ?? '',
      contact: json['contact'] ?? '',
      requestedItems:
          List<String>.from(
            json['requestedItems'] ?? [],
          ),
      requestedMessage:
          json['requestedMessage'],
      orderStatus:
          json['orderStatus'] ?? '',
      piLink: json['piLink'],
      paymentLink:
          json['paymentLink'],
      poLink: json['poLink']
    );
  }
}