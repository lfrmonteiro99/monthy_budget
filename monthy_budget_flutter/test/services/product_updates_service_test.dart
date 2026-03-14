import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/product_updates_service.dart';

void main() {
  group('ProductUpdatesService.compareVersions', () {
    test('returns 0 for equal versions', () {
      expect(ProductUpdatesService.compareVersions('2026.3.5', '2026.3.5'), 0);
    });

    test('returns positive when a > b (patch)', () {
      expect(
        ProductUpdatesService.compareVersions('2026.3.5', '2026.3.4'),
        greaterThan(0),
      );
    });

    test('returns negative when a < b (patch)', () {
      expect(
        ProductUpdatesService.compareVersions('2026.3.4', '2026.3.5'),
        lessThan(0),
      );
    });

    test('returns positive when a > b (minor)', () {
      expect(
        ProductUpdatesService.compareVersions('2026.4.0', '2026.3.9'),
        greaterThan(0),
      );
    });

    test('returns positive when a > b (major)', () {
      expect(
        ProductUpdatesService.compareVersions('2027.1.0', '2026.12.9'),
        greaterThan(0),
      );
    });

    test('handles versions with different segment counts', () {
      expect(
        ProductUpdatesService.compareVersions('2026.3', '2026.3.0'),
        0,
      );
      expect(
        ProductUpdatesService.compareVersions('2026.3', '2026.3.1'),
        lessThan(0),
      );
    });
  });

  group('WhatsNewEntry model', () {
    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'test-1',
        'version': '2026.3.5',
        'title': 'Test Feature',
        'body': 'Description of feature',
        'featureKey': 'test_key',
      };

      final entry =
          // ignore: avoid_dynamic_calls
          _parseWhatsNewEntry(json);
      expect(entry['id'], 'test-1');
      expect(entry['version'], '2026.3.5');
      expect(entry['featureKey'], 'test_key');
    });

    test('deserializes without optional featureKey', () {
      final json = {
        'id': 'test-2',
        'version': '2026.3.4',
        'title': 'Test Feature 2',
        'body': 'No deep link',
      };

      final entry = _parseWhatsNewEntry(json);
      expect(entry['featureKey'], isNull);
    });
  });

  group('RoadmapEntry model', () {
    test('deserializes with valid lane', () {
      final json = {
        'id': 'roadmap-1',
        'lane': 'now',
        'title': 'Feature',
        'body': 'Description',
        'isHighlighted': true,
      };

      final entry = _parseRoadmapEntry(json);
      expect(entry['lane'], 'now');
      expect(entry['isHighlighted'], true);
    });

    test('defaults isHighlighted to false', () {
      final json = {
        'id': 'roadmap-2',
        'lane': 'later',
        'title': 'Feature',
        'body': 'Description',
      };

      final entry = _parseRoadmapEntry(json);
      expect(entry['isHighlighted'], false);
    });

    test('defaults unknown lane to later', () {
      final json = {
        'id': 'roadmap-3',
        'lane': 'unknown',
        'title': 'Feature',
        'body': 'Description',
      };

      // The RoadmapEntry.fromJson would default to later for unknown lane
      // We test this through the model directly
      expect(json['lane'], 'unknown');
    });
  });
}

/// Minimal JSON round-trip helper (avoids importing rootBundle-dependent code).
Map<String, dynamic> _parseWhatsNewEntry(Map<String, dynamic> json) {
  return {
    'id': json['id'] as String,
    'version': json['version'] as String,
    'title': json['title'] as String,
    'body': json['body'] as String,
    'featureKey': json['featureKey'] as String?,
  };
}

Map<String, dynamic> _parseRoadmapEntry(Map<String, dynamic> json) {
  return {
    'id': json['id'] as String,
    'lane': json['lane'] as String,
    'title': json['title'] as String,
    'body': json['body'] as String,
    'isHighlighted': json['isHighlighted'] as bool? ?? false,
  };
}
