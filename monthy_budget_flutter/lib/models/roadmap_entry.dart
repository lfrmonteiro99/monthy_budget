enum RoadmapLane { now, next, later }

class RoadmapEntry {
  final String id;
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

  factory RoadmapEntry.fromJson(Map<String, dynamic> json) {
    return RoadmapEntry(
      id: json['id'] as String,
      lane: RoadmapLane.values.firstWhere(
        (l) => l.name == json['lane'],
        orElse: () => RoadmapLane.later,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lane': lane.name,
        'title': title,
        'body': body,
        'isHighlighted': isHighlighted,
      };
}
