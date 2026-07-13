class TechnicianModel {
  final String technicianId;
  final String name;
  final String phone;
  final String? photoUrl;
  final String area;

  const TechnicianModel({
    required this.technicianId,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.area,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      technicianId: json['technicianId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
      area: json['area'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technicianId': technicianId,
      'name': name,
      'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'area': area,
    };
  }

  TechnicianModel copyWith({
    String? technicianId,
    String? name,
    String? phone,
    String? photoUrl,
    String? area,
  }) {
    return TechnicianModel(
      technicianId: technicianId ?? this.technicianId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      area: area ?? this.area,
    );
  }
}
