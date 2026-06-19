import 'package:goodlife_party/models/additional_document.dart';

class CustomOrderModel {
  final String area;
  final String orderedBy;
  final String deviceToken;
  final String contact;

  final String orderDate;
  final String orderTime;

  final List<String> requestedItems;

  final String? requestedMessage;

  final String orderStatus;

  final String? piLink;
  final String? paymentLink;
  final String? poLink;
  final String? firebaseOrderId;

  final List<AdditionalDocument> additionalDocuments;

  CustomOrderModel({
    required this.area,
    required this.orderedBy,
    required this.deviceToken,
    required this.contact,
    required this.orderDate,
    required this.orderTime,
    required this.requestedItems,
    required this.orderStatus,
    this.requestedMessage,
    required this.firebaseOrderId,
    this.piLink,
    this.paymentLink,
    this.poLink,
    this.additionalDocuments = const [],
  });

  factory CustomOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomOrderModel(
      area: json['area'] ?? '',
      orderedBy: json['orderedBy'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      contact: json['contact'] ?? '',
      orderDate: json['orderDate'] ?? '',
      orderTime: json['orderTime'] ?? '',
      requestedItems: List<String>.from(
        json['requestedItems'] ?? [],
      ),
      requestedMessage: json['requestedMessage'],
      orderStatus: json['orderStatus'] ?? 'INQUIRY',
      piLink: json['piLink'],
      paymentLink: json['paymentLink'],
      poLink: json['poLink'],
      firebaseOrderId: json['firebaseOrderId'],
      additionalDocuments:
          (json['additionalDocuments'] as List?)
              ?.map((e) {
                if (e is String) {
                  return AdditionalDocument(
                    url: e,
                    type: 'pdf',
                  );
                }

                return AdditionalDocument.fromJson(
                  Map<dynamic, dynamic>.from(e),
                );
              })
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'orderedBy': orderedBy,
      'deviceToken': deviceToken,
      'contact': contact,
      'orderDate': orderDate,
      'orderTime': orderTime,
      'requestedItems': requestedItems,
      'requestedMessage': requestedMessage,
      'orderStatus': orderStatus,
      'piLink': piLink,
      'paymentLink': paymentLink,
      'poLink': poLink,
      'additionalDocuments':
          additionalDocuments
              .map((e) => e.toJson())
              .toList(),
      'firebaseOrderId': firebaseOrderId,
    };
  }
}