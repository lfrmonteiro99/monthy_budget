import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';

void main() {
  group('LocalDashboardConfig', () {
    test('default config is focused for cleaner home experience', () {
      const config = LocalDashboardConfig();

      expect(config.showHeroCard, isTrue);
      expect(config.showStressIndex, isTrue);
      expect(config.showSummaryCards, isTrue);
      expect(config.showBudgetVsActual, isTrue);
      expect(config.showCharts, isFalse);
      expect(config.showPurchaseHistory, isFalse);
      expect(config.cardOrder, LocalDashboardConfig.defaultCardOrder);
    });

    test('Tier 1 cards enabled by default', () {
      const config = LocalDashboardConfig();

      expect(config.showCashFlowForecast, isTrue);
      expect(config.showBurnRate, isTrue);
      expect(config.showTopCategories, isTrue);
      expect(config.showSavingsRate, isTrue);
      expect(config.showCoachInsight, isTrue);
    });

    test('Tier 1 cards included in default card order', () {
      expect(LocalDashboardConfig.defaultCardOrder, contains('cashFlowForecast'));
      expect(LocalDashboardConfig.defaultCardOrder, contains('burnRate'));
      expect(LocalDashboardConfig.defaultCardOrder, contains('topCategories'));
      expect(LocalDashboardConfig.defaultCardOrder, contains('savingsRate'));
      expect(LocalDashboardConfig.defaultCardOrder, contains('coachInsight'));
    });

    test('Tier 1 cards visible via isCardVisible', () {
      const config = LocalDashboardConfig();

      expect(config.isCardVisible('cashFlowForecast'), isTrue);
      expect(config.isCardVisible('burnRate'), isTrue);
      expect(config.isCardVisible('topCategories'), isTrue);
      expect(config.isCardVisible('savingsRate'), isTrue);
      expect(config.isCardVisible('coachInsight'), isTrue);
    });

    test('Tier 1 cards toggled off via setCardVisible', () {
      const config = LocalDashboardConfig();
      final updated = config.setCardVisible('burnRate', false);
      expect(updated.isCardVisible('burnRate'), isFalse);
      expect(updated.isCardVisible('topCategories'), isTrue);
    });

    test('Tier 1 cards survive JSON roundtrip', () {
      const config = LocalDashboardConfig(
        showCashFlowForecast: false,
        showBurnRate: true,
        showTopCategories: false,
        showSavingsRate: true,
        showCoachInsight: false,
      );

      final decoded = LocalDashboardConfig.fromJsonString(config.toJsonString());

      expect(decoded.showCashFlowForecast, isFalse);
      expect(decoded.showBurnRate, isTrue);
      expect(decoded.showTopCategories, isFalse);
      expect(decoded.showSavingsRate, isTrue);
      expect(decoded.showCoachInsight, isFalse);
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

    test('cardOrder JSON roundtrip preserves custom order', () {
      const customOrder = ['charts', 'heroCard', 'stressIndex'];
      const config = LocalDashboardConfig(cardOrder: customOrder);

      final decoded = LocalDashboardConfig.fromJsonString(config.toJsonString());
      expect(decoded.cardOrder, customOrder);
    });

    test('cardOrder defaults when missing from JSON', () {
      final decoded = LocalDashboardConfig.fromJson({'showHeroCard': true});
      expect(decoded.cardOrder, LocalDashboardConfig.defaultCardOrder);
    });

    test('copyWith preserves cardOrder when not specified', () {
      const customOrder = ['charts', 'heroCard'];
      const config = LocalDashboardConfig(cardOrder: customOrder);
      final updated = config.copyWith(showCharts: true);
      expect(updated.cardOrder, customOrder);
      expect(updated.showCharts, isTrue);
    });

    test('isCardVisible returns correct values', () {
      const config = LocalDashboardConfig(showHeroCard: true, showCharts: false);
      expect(config.isCardVisible('heroCard'), isTrue);
      expect(config.isCardVisible('charts'), isFalse);
      expect(config.isCardVisible('quickActions'), isTrue);
      expect(config.isCardVisible('unknown'), isFalse);
    });

    test('setCardVisible toggles a specific card', () {
      const config = LocalDashboardConfig(showCharts: false);
      final updated = config.setCardVisible('charts', true);
      expect(updated.showCharts, isTrue);
      expect(updated.showHeroCard, config.showHeroCard);
    });
  });
}
