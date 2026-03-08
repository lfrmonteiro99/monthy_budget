import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/product.dart';
import 'package:orcamento_mensal/models/scanned_product_candidate.dart';
import 'package:orcamento_mensal/services/barcode_scan_service.dart';

void main() {
  group('BarcodeScanService', () {
    late BarcodeScanService service;

    setUp(() {
      service = BarcodeScanService();
    });

    group('lookup with cached products', () {
      test('returns matched product when barcode is in cache', () async {
        final product = Product(
          id: 'p1',
          name: 'Leite Meio-Gordo',
          category: 'Laticinios',
          avgPrice: 0.79,
          unit: 'L',
          barcode: '5601234567890',
        );
        service.updateCachedProducts([product]);

        final candidate = await service.lookup('5601234567890');

        expect(candidate.hasMatch, true);
        expect(candidate.matchedProduct, product);
        expect(candidate.confidence, 1.0);
        expect(candidate.source, BarcodeLookupSource.cached);
        expect(candidate.barcode, '5601234567890');
      });

      test('returns no match when barcode is not in cache', () async {
        final product = Product(
          id: 'p1',
          name: 'Leite',
          category: 'Laticinios',
          avgPrice: 0.79,
          unit: 'L',
          barcode: '1111111111111',
        );
        service.updateCachedProducts([product]);

        final candidate = await service.lookup('9999999999999');

        // Falls through to bundled asset (which will fail in test env) then manual
        expect(candidate.hasMatch, false);
        expect(candidate.barcode, '9999999999999');
        expect(candidate.source, BarcodeLookupSource.manual);
      });

      test('skips products without barcodes', () async {
        final product = Product(
          id: 'p1',
          name: 'Leite',
          category: 'Laticinios',
          avgPrice: 0.79,
          unit: 'L',
        );
        service.updateCachedProducts([product]);

        final candidate = await service.lookup('5601234567890');

        expect(candidate.hasMatch, false);
      });
    });

    group('manual fallback', () {
      test('returns manual source when no products cached and no asset', () async {
        final candidate = await service.lookup('0000000000000');

        expect(candidate.hasMatch, false);
        expect(candidate.barcode, '0000000000000');
        expect(candidate.source, BarcodeLookupSource.manual);
        expect(candidate.confidence, 0.0);
      });
    });
  });

  group('ScannedProductCandidate', () {
    test('hasMatch returns true when matchedProduct is not null', () {
      final candidate = ScannedProductCandidate(
        barcode: '123',
        matchedProduct: const Product(
          id: 'p1',
          name: 'Test',
          category: 'cat',
          avgPrice: 1.0,
          unit: 'un',
        ),
        confidence: 1.0,
        source: BarcodeLookupSource.cached,
      );

      expect(candidate.hasMatch, true);
    });

    test('hasMatch returns false when matchedProduct is null', () {
      const candidate = ScannedProductCandidate(
        barcode: '123',
        source: BarcodeLookupSource.manual,
      );

      expect(candidate.hasMatch, false);
    });

    test('equality works correctly', () {
      const product = Product(
        id: 'p1',
        name: 'Test',
        category: 'cat',
        avgPrice: 1.0,
        unit: 'un',
      );

      final a = ScannedProductCandidate(
        barcode: '123',
        matchedProduct: product,
        confidence: 1.0,
        source: BarcodeLookupSource.cached,
      );

      final b = ScannedProductCandidate(
        barcode: '123',
        matchedProduct: product,
        confidence: 1.0,
        source: BarcodeLookupSource.cached,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different barcodes are not equal', () {
      const a = ScannedProductCandidate(
        barcode: '123',
        source: BarcodeLookupSource.manual,
      );
      const b = ScannedProductCandidate(
        barcode: '456',
        source: BarcodeLookupSource.manual,
      );

      expect(a, isNot(b));
    });
  });
}
