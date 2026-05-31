class OrderItemModel {
  final String name;
  final num price;
  final num quantity;
  final num totalPrice;
  final String customizationMessage;

  OrderItemModel({
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.customizationMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      "quantity": quantity,
      "totalPrice": totalPrice,
      "customizationMessage":
          customizationMessage,
    };
  }
}