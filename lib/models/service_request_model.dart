class ServiceRequestModel {
  final String serviceRequestId;
  final List<String> machineIds;
  final List<String> machineNames;
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
  final String status; // 'PENDING', 'IN_PROGRESS', 'RESOLVED'
  final String? happyCode; // Assigned by admin when service is completed

  ServiceRequestModel({
    required this.serviceRequestId,
    required this.machineIds,
    required this.machineNames,
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
    this.happyCode,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      serviceRequestId: json['serviceRequestId'] ?? '',
      machineIds: List<String>.from(json['machineIds'] ?? []),
      machineNames: List<String>.from(json['machineNames'] ?? []),
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
      happyCode: json['happyCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceRequestId': serviceRequestId,
      'machineIds': machineIds,
      'machineNames': machineNames,
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
      if (happyCode != null) 'happyCode': happyCode,
    };
  }

  ServiceRequestModel copyWith({
    String? serviceRequestId,
    List<String>? machineIds,
    List<String>? machineNames,
    String? area,
    String? orderedBy,
    String? deviceToken,
    String? contact,
    String? requestDate,
    String? requestTime,
    String? type,
    String? description,
    List<String>? imageUrls,
    String? audioUrl,
    String? status,
    String? happyCode,
  }) {
    return ServiceRequestModel(
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      machineIds: machineIds ?? this.machineIds,
      machineNames: machineNames ?? this.machineNames,
      area: area ?? this.area,
      orderedBy: orderedBy ?? this.orderedBy,
      deviceToken: deviceToken ?? this.deviceToken,
      contact: contact ?? this.contact,
      requestDate: requestDate ?? this.requestDate,
      requestTime: requestTime ?? this.requestTime,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      happyCode: happyCode ?? this.happyCode,
    );
  }
}
