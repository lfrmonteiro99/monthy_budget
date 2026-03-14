import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';

void main() {
  group('LocalDashboardConfig', () {
    test('default config is focused for cleaner home experience', () {
      const config = LocalDashboardConfig();

      expect(config.showHeroCard, isTrue);
      expect(config.showStressIndex, isTrue);
      expect(config.showSummaryCards, isFalse);
      expect(config.showCharts, isFalse);
      expect(config.showPurchaseHistory, isFalse);
    });

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
      expect(decoded.showCharts, isFalse);
    });

    test('full preset enables full analytics dashboard', () {
      final config = LocalDashboardConfig.full();
      expect(config.showSummaryCards, isTrue);
      expect(config.showSalaryBreakdown, isTrue);
      expect(config.showPurchaseHistory, isTrue);
      expect(config.showCharts, isTrue);
    });
  });
}
