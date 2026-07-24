// models/login_context.dart

class LoginContext {
  final DistributorDetails distributorDetails;
  final AreaDetails areaDetails;

  LoginContext({
    required this.distributorDetails,
    required this.areaDetails,
  });

  factory LoginContext.fromJson(Map<String, dynamic> json) {
    return LoginContext(
      distributorDetails: DistributorDetails.fromJson(
        json['distributorDetails'],
      ),
      areaDetails: AreaDetails.fromJson(
        json['areaDetails'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distributorDetails': distributorDetails.toJson(),
      'areaDetails': areaDetails.toJson(),
    };
  }

  LoginContext copyWith({DistributorDetails? distributorDetails}) {
    return LoginContext(
      distributorDetails: distributorDetails ?? this.distributorDetails,
      areaDetails: areaDetails,
    );
  }
}

class DistributorDetails {
  final bool allowPayLater;
  final String area;
  final String address;
  final String contact;
  final String deviceToken;
  final String distributorName;
  final List<String> machineIds;

  DistributorDetails({
    required this.allowPayLater,
    required this.area,
    required this.address,
    required this.contact,
    required this.deviceToken,
    required this.distributorName,
    required this.machineIds,
  });

  factory DistributorDetails.fromJson(Map<String, dynamic> json) {
    return DistributorDetails(
      allowPayLater: json['allowPayLater'] ?? false,
      area: json['area'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      distributorName: json['distributorName'] ?? '',
      machineIds: List<String>.from(
        json['machineIds'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowPayLater': allowPayLater,
      'area': area,
      'address': address,
      'contact': contact,
      'deviceToken': deviceToken,
      'distributorName': distributorName,
      'machineIds': machineIds,
    };
  }

  DistributorDetails copyWith({String? deviceToken}) {
    return DistributorDetails(
      allowPayLater: allowPayLater,
      area: area,
      address: address,
      contact: contact,
      deviceToken: deviceToken ?? this.deviceToken,
      distributorName: distributorName,
      machineIds: machineIds,
    );
  }
}

class AreaDetails {
  final double amcPrice;
  final int amcServices;
  final String areaName;
  final double freightPercentage;
  final int salesContact;
  final String salesPerson;

  AreaDetails({
    required this.amcPrice,
    required this.amcServices,
    required this.areaName,
    required this.freightPercentage,
    required this.salesContact,
    required this.salesPerson,
  });

  factory AreaDetails.fromJson(
  Map<String, dynamic> json,
) {
  return AreaDetails(
    amcPrice:
        (json['amcPrice'] ?? 0).toDouble(),

    amcServices:
        json['amcServices'] ?? 0,

    areaName:
        json['areaName'] ?? '',

    freightPercentage:
        (json['freightPercentage'] ?? 0)
            .toDouble(),

    salesContact:
        json['salesContact'] ?? 0,

    salesPerson:
        json['salesPerson'] ?? '',
  );
}

  Map<String, dynamic> toJson() {
    return {
      'amcPrice': amcPrice,
      'amcServices': amcServices,
      'areaName': areaName,
      'freightPercentage': freightPercentage,
      'salesContact': salesContact,
      'salesPerson': salesPerson,
    };
  }
}