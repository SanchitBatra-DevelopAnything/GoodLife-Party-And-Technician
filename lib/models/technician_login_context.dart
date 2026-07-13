import 'technician_model.dart';

class TechnicianLoginContext {
  final TechnicianModel technician;

  const TechnicianLoginContext({required this.technician});

  factory TechnicianLoginContext.fromJson(Map<String, dynamic> json) {
    return TechnicianLoginContext(
      technician: TechnicianModel.fromJson(
        Map<String, dynamic>.from(json['technician'] ?? json),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'technician': technician.toJson()};
  }
}
