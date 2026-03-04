import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/models/local_dashboard_config.dart';

void main() {
  group('LocalDashboardConfig', () {
    test('minimalist preset disables most widgets', () {
      final config = LocalDashboardConfig.minimalist();

      expect(config.showHeroCard, isTrue);
      expect(config.showStressIndex, isFalse);
      expect(config.showCharts, isFalse);
      expect(config.enabledCharts, isEmpty);
    });

    test('copyWith updates selected fields only', () {
      const base = LocalDashboardConfig();
      final updated = base.copyWith(
        showStressIndex: false,
        enabledCharts: const [ChartType.expensesPie],
      );

      expect(updated.showStressIndex, isFalse);
      expect(updated.showHeroCard, base.showHeroCard);
      expect(updated.enabledCharts, const [ChartType.expensesPie]);
    });

    test('JSON roundtrip keeps values', () {
      const config = LocalDashboardConfig(
        showHeroCard: false,
        showStressIndex: false,
        showCharts: true,
        enabledCharts: [ChartType.savingsRate],
      );

      final decoded = LocalDashboardConfig.fromJsonString(config.toJsonString());

      expect(decoded.showHeroCard, isFalse);
      expect(decoded.showStressIndex, isFalse);
      expect(decoded.showCharts, isTrue);
      expect(decoded.enabledCharts, const [ChartType.savingsRate]);
    });

    test('fromJsonString falls back to defaults on invalid payload', () {
      final decoded = LocalDashboardConfig.fromJsonString('not-json');
      expect(decoded.showHeroCard, isTrue);
      expect(decoded.showStressIndex, isTrue);
    });
  });
}
