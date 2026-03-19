import 'package:json_annotation/json_annotation.dart';

part 'whats_new_entry.g.dart';

@JsonSerializable(includeIfNull: false)
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

  factory WhatsNewEntry.fromJson(Map<String, dynamic> json) =>
      _$WhatsNewEntryFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsNewEntryToJson(this);
}
