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
  final String status; // PENDING, IN_PROGRESS, CLOSED, VERIFIED, RESOLVED
  final String? happyCode;
  final String? address;
  final String? assignedTechnicianId;
  final List<String> preWorkImageUrls;
  final List<String> postWorkImageUrls;
  final bool serviceDone;
  final bool cleaningDone;
  final String? serviceReportImageUrl;
  final String? googleReviewImageUrl;
  final String? paymentMode; // UPI or CASH
  final double? paymentAmount;
  final String? paymentReceiptImageUrl;
  final String? invoiceUrl;
  final String? assignedTechnicianName;
  final String? assignedTechnicianPhone;
  final String? firebasePushId; // RTDB key under /serviceRequests/{orderedBy}/
  final int? technicianRating; // 1–5, submitted by party user after close
  final String? technicianRatingComment;
  final String? technicianRatingAt;

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
    this.address,
    this.assignedTechnicianId,
    this.preWorkImageUrls = const [],
    this.postWorkImageUrls = const [],
    this.serviceDone = false,
    this.cleaningDone = false,
    this.serviceReportImageUrl,
    this.googleReviewImageUrl,
    this.paymentMode,
    this.paymentAmount,
    this.paymentReceiptImageUrl,
    this.invoiceUrl,
    this.assignedTechnicianName,
    this.assignedTechnicianPhone,
    this.firebasePushId,
    this.technicianRating,
    this.technicianRatingComment,
    this.technicianRatingAt,
  });

  bool get hasTechnicianRating =>
      technicianRating != null && technicianRating! >= 1 && technicianRating! <= 5;

  bool get canRateTechnician =>
      isCompleted && hasAssignedTechnician && !hasTechnicianRating;

  String get displayAddress =>
      (address != null && address!.trim().isNotEmpty) ? address!.trim() : area;

  String get shortAddress {
    final full = displayAddress;
    if (full.length <= 40) return full;
    return '${full.substring(0, 37)}...';
  }

  bool get isActive {
    final s = status.toUpperCase();
    return s != 'CLOSED' &&
        s != 'VERIFIED' &&
        s != 'RESOLVED' &&
        s != 'CLOSED_BY_ADMIN' &&
        assignedTechnicianId != null &&
        assignedTechnicianId!.isNotEmpty;
  }

  bool get hasAssignedTechnician =>
      assignedTechnicianId != null && assignedTechnicianId!.isNotEmpty;

  bool get isCompleted =>
      status.toUpperCase() == 'CLOSED' ||
      status.toUpperCase() == 'VERIFIED' ||
      status.toUpperCase() == 'RESOLVED' ||
      status.toUpperCase() == 'CLOSED_BY_ADMIN';

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
      address: json['address']?.toString().trim().isNotEmpty == true
          ? json['address'].toString().trim()
          : null,
      assignedTechnicianId: json['assignedTechnicianId'] as String?,
      preWorkImageUrls: List<String>.from(json['preWorkImageUrls'] ?? []),
      postWorkImageUrls: List<String>.from(json['postWorkImageUrls'] ?? []),
      serviceDone: json['serviceDone'] == true,
      cleaningDone: json['cleaningDone'] == true,
      serviceReportImageUrl: json['serviceReportImageUrl'] as String?,
      googleReviewImageUrl: json['googleReviewImageUrl'] as String?,
      paymentMode: json['paymentMode'] as String?,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
      paymentReceiptImageUrl: json['paymentReceiptImageUrl'] as String?,
      invoiceUrl: (json['invoiceUrl'] ?? json['invoiceImageUrl']) as String?,
      assignedTechnicianName: json['assignedTechnicianName'] as String?,
      assignedTechnicianPhone: (json['assignedTechnicianPhone'] ??
              json['assignedTechnicianMobile'] ??
              json['assignedTechnicianContact'])
          ?.toString(),
      firebasePushId: json['firebasePushId'] as String?,
      technicianRating: (json['technicianRating'] as num?)?.toInt(),
      technicianRatingComment: json['technicianRatingComment'] as String?,
      technicianRatingAt: json['technicianRatingAt'] as String?,
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
      if (address != null) 'address': address,
      if (assignedTechnicianId != null)
        'assignedTechnicianId': assignedTechnicianId,
      'preWorkImageUrls': preWorkImageUrls,
      'postWorkImageUrls': postWorkImageUrls,
      'serviceDone': serviceDone,
      'cleaningDone': cleaningDone,
      if (serviceReportImageUrl != null)
        'serviceReportImageUrl': serviceReportImageUrl,
      if (googleReviewImageUrl != null)
        'googleReviewImageUrl': googleReviewImageUrl,
      if (paymentMode != null) 'paymentMode': paymentMode,
      if (paymentAmount != null) 'paymentAmount': paymentAmount,
      if (paymentReceiptImageUrl != null)
        'paymentReceiptImageUrl': paymentReceiptImageUrl,
      if (invoiceUrl != null) 'invoiceUrl': invoiceUrl,
      if (assignedTechnicianName != null)
        'assignedTechnicianName': assignedTechnicianName,
      if (assignedTechnicianPhone != null)
        'assignedTechnicianPhone': assignedTechnicianPhone,
      if (firebasePushId != null) 'firebasePushId': firebasePushId,
      if (technicianRating != null) 'technicianRating': technicianRating,
      if (technicianRatingComment != null)
        'technicianRatingComment': technicianRatingComment,
      if (technicianRatingAt != null) 'technicianRatingAt': technicianRatingAt,
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
    String? address,
    String? assignedTechnicianId,
    List<String>? preWorkImageUrls,
    List<String>? postWorkImageUrls,
    bool? serviceDone,
    bool? cleaningDone,
    String? serviceReportImageUrl,
    String? googleReviewImageUrl,
    String? paymentMode,
    double? paymentAmount,
    String? paymentReceiptImageUrl,
    String? invoiceUrl,
    String? assignedTechnicianName,
    String? assignedTechnicianPhone,
    String? firebasePushId,
    int? technicianRating,
    String? technicianRatingComment,
    String? technicianRatingAt,
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
      address: address ?? this.address,
      assignedTechnicianId:
          assignedTechnicianId ?? this.assignedTechnicianId,
      preWorkImageUrls: preWorkImageUrls ?? this.preWorkImageUrls,
      postWorkImageUrls: postWorkImageUrls ?? this.postWorkImageUrls,
      serviceDone: serviceDone ?? this.serviceDone,
      cleaningDone: cleaningDone ?? this.cleaningDone,
      serviceReportImageUrl:
          serviceReportImageUrl ?? this.serviceReportImageUrl,
      googleReviewImageUrl:
          googleReviewImageUrl ?? this.googleReviewImageUrl,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentReceiptImageUrl:
          paymentReceiptImageUrl ?? this.paymentReceiptImageUrl,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      assignedTechnicianName:
          assignedTechnicianName ?? this.assignedTechnicianName,
      assignedTechnicianPhone:
          assignedTechnicianPhone ?? this.assignedTechnicianPhone,
      firebasePushId: firebasePushId ?? this.firebasePushId,
      technicianRating: technicianRating ?? this.technicianRating,
      technicianRatingComment:
          technicianRatingComment ?? this.technicianRatingComment,
      technicianRatingAt: technicianRatingAt ?? this.technicianRatingAt,
    );
  }
}
