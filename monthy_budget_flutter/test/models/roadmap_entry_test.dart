import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/roadmap_entry.dart';

void main() {
  group('RoadmapEntry', () {
    test('fromJson creates entry with now lane', () {
      final entry = RoadmapEntry.fromJson({
        'id': 'r1',
        'lane': 'now',
        'title': 'Feature',
        'body': 'Description',
        'isHighlighted': true,
      });

      expect(entry.id, 'r1');
      expect(entry.lane, RoadmapLane.now);
      expect(entry.title, 'Feature');
      expect(entry.isHighlighted, true);
    });

    test('fromJson creates entry with next lane', () {
      final entry = RoadmapEntry.fromJson({
        'id': 'r2',
        'lane': 'next',
        'title': 'Feature 2',
        'body': 'Description 2',
      });

      expect(entry.lane, RoadmapLane.next);
      expect(entry.isHighlighted, false);
    });

    test('fromJson defaults unknown lane to later', () {
      final entry = RoadmapEntry.fromJson({
        'id': 'r3',
        'lane': 'invalid_lane',
        'title': 'Feature 3',
        'body': 'Description 3',
      });

      expect(entry.lane, RoadmapLane.later);
    });

    test('fromJson defaults isHighlighted to false when absent', () {
      final entry = RoadmapEntry.fromJson({
        'id': 'r4',
        'lane': 'later',
        'title': 'Feature 4',
        'body': 'Description 4',
      });

      expect(entry.isHighlighted, false);
    });

    test('toJson round-trips correctly', () {
      const entry = RoadmapEntry(
        id: 'test',
        lane: RoadmapLane.next,
        title: 'Title',
        body: 'Body',
        isHighlighted: true,
      );

      final json = entry.toJson();
      final restored = RoadmapEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.lane, entry.lane);
      expect(restored.title, entry.title);
      expect(restored.body, entry.body);
      expect(restored.isHighlighted, entry.isHighlighted);
    });
  });

  group('RoadmapLane', () {
    test('has all expected values', () {
      expect(RoadmapLane.values, containsAll([
        RoadmapLane.now,
        RoadmapLane.next,
        RoadmapLane.later,
      ]));
      expect(RoadmapLane.values.length, 3);
    });
  });
}
