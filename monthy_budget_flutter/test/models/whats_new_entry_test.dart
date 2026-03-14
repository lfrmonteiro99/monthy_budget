import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/whats_new_entry.dart';

void main() {
  group('WhatsNewEntry', () {
    test('fromJson creates entry with all fields', () {
      final entry = WhatsNewEntry.fromJson({
        'id': 'v1-feature',
        'version': '2026.3.5',
        'title': 'New Feature',
        'body': 'Feature description',
        'featureKey': 'savings_goals',
      });

      expect(entry.id, 'v1-feature');
      expect(entry.version, '2026.3.5');
      expect(entry.title, 'New Feature');
      expect(entry.body, 'Feature description');
      expect(entry.featureKey, 'savings_goals');
    });

    test('fromJson handles missing featureKey', () {
      final entry = WhatsNewEntry.fromJson({
        'id': 'v1-other',
        'version': '2026.3.4',
        'title': 'Bug Fix',
        'body': 'Fixed stuff',
      });

      expect(entry.featureKey, isNull);
    });

    test('toJson round-trips correctly', () {
      const entry = WhatsNewEntry(
        id: 'test',
        version: '1.0.0',
        title: 'Title',
        body: 'Body',
        featureKey: 'key',
      );

      final json = entry.toJson();
      final restored = WhatsNewEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.version, entry.version);
      expect(restored.title, entry.title);
      expect(restored.body, entry.body);
      expect(restored.featureKey, entry.featureKey);
    });

    test('toJson omits featureKey when null', () {
      const entry = WhatsNewEntry(
        id: 'test',
        version: '1.0.0',
        title: 'Title',
        body: 'Body',
      );

      final json = entry.toJson();
      expect(json.containsKey('featureKey'), isFalse);
    });
  });
}
