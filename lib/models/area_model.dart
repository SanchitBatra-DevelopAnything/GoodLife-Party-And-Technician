class AreaModel {
  final String id;
  final String name;
  final int amcPrice;
  final int amcServices;
  final int freightPercentage;

  AreaModel({
    required this.id,
    required this.name,
    required this.amcPrice,
    required this.amcServices,
    required this.freightPercentage,
  });

  factory AreaModel.fromJson(String id, Map<String, dynamic> json) {
    return AreaModel(
      id: id,
      name: json['areaName'] ?? '',
      amcPrice: json['amcPrice'] ?? 0,
      amcServices: json['amcServices'] ?? 0,
      freightPercentage: json['freightPercentage'] ?? 0,
    );
  }
}