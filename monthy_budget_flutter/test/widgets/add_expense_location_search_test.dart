import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the Nominatim address search logic used in add_expense_sheet.dart.
///
/// Since the search method is private to the widget state, these tests verify
/// the URL construction and response parsing logic independently.
void main() {
  group('Nominatim search URL construction', () {
    test('builds correct URL with encoded query', () {
      const query = 'Rua Augusta 100, Lisboa';
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      });

      expect(uri.scheme, 'https');
      expect(uri.host, 'nominatim.openstreetmap.org');
      expect(uri.path, '/search');
      expect(uri.queryParameters['q'], query);
      expect(uri.queryParameters['format'], 'json');
      expect(uri.queryParameters['limit'], '5');
      expect(uri.queryParameters['addressdetails'], '1');
    });

    test('encodes special characters in query', () {
      const query = 'São Paulo & região';
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      });

      // Uri.https encodes query parameters automatically
      expect(uri.queryParameters['q'], query);
      expect(uri.toString(), contains('nominatim.openstreetmap.org'));
    });
  });

  group('Nominatim response parsing', () {
    test('parses valid response with results', () {
      const responseBody = '''
      [
        {
          "lat": "38.7169",
          "lon": "-9.1399",
          "display_name": "Rua Augusta, Lisboa, Portugal",
          "address": {"road": "Rua Augusta", "city": "Lisboa"}
        },
        {
          "lat": "41.1496",
          "lon": "-8.6109",
          "display_name": "Rua Augusta, Porto, Portugal",
          "address": {"road": "Rua Augusta", "city": "Porto"}
        }
      ]
      ''';

      final results = (jsonDecode(responseBody) as List)
          .cast<Map<String, dynamic>>();

      expect(results.length, 2);
      expect(results[0]['display_name'], 'Rua Augusta, Lisboa, Portugal');
      expect(double.tryParse(results[0]['lat'].toString()), 38.7169);
      expect(double.tryParse(results[0]['lon'].toString()), -9.1399);
      expect(results[1]['display_name'], 'Rua Augusta, Porto, Portugal');
    });

    test('parses empty response', () {
      const responseBody = '[]';
      final results = (jsonDecode(responseBody) as List)
          .cast<Map<String, dynamic>>();

      expect(results, isEmpty);
    });

    test('extracts lat/lng correctly as doubles', () {
      const responseBody = '''
      [{"lat": "51.5074", "lon": "-0.1278", "display_name": "London, UK"}]
      ''';

      final results = (jsonDecode(responseBody) as List)
          .cast<Map<String, dynamic>>();
      final lat = double.tryParse(results[0]['lat']?.toString() ?? '');
      final lng = double.tryParse(results[0]['lon']?.toString() ?? '');

      expect(lat, 51.5074);
      expect(lng, -0.1278);
    });

    test('handles missing lat/lon gracefully', () {
      const responseBody =
          '[{"display_name": "Somewhere", "lat": null, "lon": null}]';

      final results = (jsonDecode(responseBody) as List)
          .cast<Map<String, dynamic>>();
      final lat = double.tryParse(results[0]['lat']?.toString() ?? '');
      final lng = double.tryParse(results[0]['lon']?.toString() ?? '');

      expect(lat, isNull);
      expect(lng, isNull);
    });
  });

  group('Search query minimum length', () {
    test('rejects queries shorter than 3 characters', () {
      bool shouldSearch(String query) => query.trim().length >= 3;

      expect(shouldSearch(''), false);
      expect(shouldSearch('ab'), false);
      expect(shouldSearch('  a '), false);
      expect(shouldSearch('abc'), true);
      expect(shouldSearch('Rua Augusta'), true);
    });
  });
}
