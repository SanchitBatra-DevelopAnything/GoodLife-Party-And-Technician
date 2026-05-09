class WhatsNewItem {
  final String type;
  final String url;

  WhatsNewItem({
    required this.type,
    required this.url,
  });

  factory WhatsNewItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsNewItem(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}