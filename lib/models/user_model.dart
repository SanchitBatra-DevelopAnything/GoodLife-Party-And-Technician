class UserModel {
  final String distributorName;
  final String contact;
  final String deviceToken;
  final String area;
  final String address;

  UserModel({
    required this.distributorName,
    required this.contact,
    required this.deviceToken,
    required this.area,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      distributorName: json['distributorName'] ?? '',
      contact: json['contact'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      area: json['area'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "distributorName": distributorName,
      "contact": contact,
      "deviceToken": deviceToken,
      "area": area,
      "address": address,
    };
  }
}