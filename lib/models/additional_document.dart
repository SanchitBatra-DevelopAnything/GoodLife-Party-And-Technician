class AdditionalDocument {
  final String url;
  final String type; // pdf or image

  AdditionalDocument({
    required this.url,
    required this.type,
  });

  factory AdditionalDocument.fromJson(Map<dynamic, dynamic> json) {
    return AdditionalDocument(
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
    };
  }
}