// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapEntry _$RoadmapEntryFromJson(Map<String, dynamic> json) => RoadmapEntry(
  id: json['id'] as String,
  lane: $enumDecode(
    _$RoadmapLaneEnumMap,
    json['lane'],
    unknownValue: RoadmapLane.later,
  ),
  title: json['title'] as String,
  body: json['body'] as String,
  isHighlighted: json['isHighlighted'] as bool? ?? false,
);

Map<String, dynamic> _$RoadmapEntryToJson(RoadmapEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lane': _$RoadmapLaneEnumMap[instance.lane]!,
      'title': instance.title,
      'body': instance.body,
      'isHighlighted': instance.isHighlighted,
    };

const _$RoadmapLaneEnumMap = {
  RoadmapLane.now: 'now',
  RoadmapLane.next: 'next',
  RoadmapLane.later: 'later',
};
