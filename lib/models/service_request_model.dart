class ServiceRequestModel {
  final String serviceRequestId;
  final String machineId;
  final String machineName;
  final String area;
  final String orderedBy;
  final String deviceToken;
  final String contact;
  final String requestDate;
  final String requestTime;
  final String type; // 'SERVICE' or 'INSTALLATION'
  final String description;
  final List<String> imageUrls;
  final String? audioUrl;
  final String status; // 'PENDING'

  ServiceRequestModel({
    required this.serviceRequestId,
    required this.machineId,
    required this.machineName,
    required this.area,
    required this.orderedBy,
    required this.deviceToken,
    required this.contact,
    required this.requestDate,
    required this.requestTime,
    required this.type,
    required this.description,
    required this.imageUrls,
    this.audioUrl,
    required this.status,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      serviceRequestId: json['serviceRequestId'] ?? '',
      machineId: json['machineId'] ?? '',
      machineName: json['machineName'] ?? '',
      area: json['area'] ?? '',
      orderedBy: json['orderedBy'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      contact: json['contact'] ?? '',
      requestDate: json['requestDate'] ?? '',
      requestTime: json['requestTime'] ?? '',
      type: json['type'] ?? 'SERVICE',
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      audioUrl: json['audioUrl'],
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceRequestId': serviceRequestId,
      'machineId': machineId,
      'machineName': machineName,
      'area': area,
      'orderedBy': orderedBy,
      'deviceToken': deviceToken,
      'contact': contact,
      'requestDate': requestDate,
      'requestTime': requestTime,
      'type': type,
      'description': description,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'status': status,
    };
  }
}
