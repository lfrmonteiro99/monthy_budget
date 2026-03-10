import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:orcamento_mensal/services/grocery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GroceryService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load defaults to PT and falls back to country asset path', () async {
      final requestedAssets = <String>[];
      final service = GroceryService(
        assetLoader: (path) async {
          requestedAssets.add(path);
          if (path == 'assets/grocery_prices.json') {
            throw Exception('missing legacy asset');
          }
          return _sampleGroceryJson(totalProducts: 1);
        },
        httpClient: _FakeHttpClient((_) async => http.Response('', 500)),
      );

      final data = await service.load();

      expect(data.metadata.totalProducts, 1);
      // Legacy path tried first for PT, then country-specific fallback
      expect(
        requestedAssets,
        ['assets/grocery_prices.json', 'assets/grocery/PT/catalog.json'],
      );
    });

    test('load uses country-aware remote url and asset path', () async {
      final requestedUrls = <Uri>[];
      final requestedAssets = <String>[];
      final service = GroceryService(
        assetLoader: (path) async {
          requestedAssets.add(path);
          return _sampleGroceryJson(totalProducts: 2);
        },
        httpClient: _FakeHttpClient((uri) async {
          requestedUrls.add(uri);
          return http.Response(_sampleGroceryJson(totalProducts: 3), 200);
        }),
      );

      final data = await service.load(countryCode: 'ES');

      expect(data.metadata.totalProducts, 3);
      expect(
        requestedUrls.single.toString(),
        'https://lfrmonteiro99.github.io/monthy_budget/assets/grocery/ES/catalog.json',
      );
      expect(requestedAssets, isEmpty);
    });

    test('cache keys are country-aware', () async {
      final service = GroceryService(
        assetLoader: (_) async => _sampleGroceryJson(totalProducts: 1),
        httpClient: _FakeHttpClient((_) async => http.Response('', 500)),
      );

      await service.load(countryCode: 'PT');
      await service.load(countryCode: 'ES');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('grocery_prices_cache_PT'), isNotNull);
      expect(prefs.getString('grocery_prices_cache_ES'), isNotNull);
    });
  });
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._handler);

  final Future<http.Response> Function(Uri uri) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request.url);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

String _sampleGroceryJson({required int totalProducts}) {
  return jsonEncode({
    'metadata': {
      'scraped_at': '2026-03-09T10:00:00Z',
      'total_products': totalProducts,
      'total_comparisons': 0,
    },
    'deco_index': {},
    'products': [],
    'comparisons': [],
    'category_summary': [],
  });
}
