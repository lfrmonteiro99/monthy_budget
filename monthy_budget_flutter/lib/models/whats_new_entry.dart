class WhatsNewEntry {
  final String id;
  final String version;
  final String title;
  final String body;
  final String? featureKey;

  const WhatsNewEntry({
    required this.id,
    required this.version,
    required this.title,
    required this.body,
    this.featureKey,
  });

  factory WhatsNewEntry.fromJson(Map<String, dynamic> json) {
    return WhatsNewEntry(
      id: json['id'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      featureKey: json['featureKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'title': title,
        'body': body,
        if (featureKey != null) 'featureKey': featureKey,
      };
}
