class ItemModel {
  final String id;
  final String itemName;
  final String details;
  final String imgUrl;
  final double price;
  final bool isCustomizable;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.details,
    required this.imgUrl,
    required this.price,
    required this.isCustomizable,
  });

  factory ItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ItemModel(
      id: id,
      itemName: map['itemName'] ?? '',
      details: map['details'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      isCustomizable: map['isCustomizable'] ?? false,
    );
  }
}