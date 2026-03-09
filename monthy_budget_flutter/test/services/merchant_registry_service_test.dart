import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/services/merchant_registry_service.dart';

void main() {
  group('MerchantInfo', () {
    test('creates from Supabase row', () {
      final info = MerchantInfo.fromSupabase({
        'nif': '500100144',
        'name': 'Continente',
        'chain': 'Sonae MC',
        'category': 'supermercado',
      });
      expect(info.nif, '500100144');
      expect(info.name, 'Continente');
      expect(info.chain, 'Sonae MC');
      expect(info.category, 'supermercado');
    });

    test('handles null chain', () {
      final info = MerchantInfo.fromSupabase({
        'nif': '123456789',
        'name': 'Loja Local',
        'chain': null,
        'category': 'outro',
      });
      expect(info.chain, isNull);
      expect(info.name, 'Loja Local');
    });

    test('defaults category to outro when null', () {
      final info = MerchantInfo.fromSupabase({
        'nif': '123456789',
        'name': 'Test',
        'chain': null,
        'category': null,
      });
      expect(info.category, 'outro');
    });
  });
}
