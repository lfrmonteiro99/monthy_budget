import 'package:json_annotation/json_annotation.dart';

part 'roadmap_entry.g.dart';

enum RoadmapLane { now, next, later }

@JsonSerializable()
class RoadmapEntry {
  final String id;
  @JsonKey(unknownEnumValue: RoadmapLane.later)
  final RoadmapLane lane;
  final String title;
  final String body;
  final bool isHighlighted;

  const RoadmapEntry({
    required this.id,
    required this.lane,
    required this.title,
    required this.body,
    this.isHighlighted = false,
  });

  factory RoadmapEntry.fromJson(Map<String, dynamic> json) =>
      _$RoadmapEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapEntryToJson(this);
}
