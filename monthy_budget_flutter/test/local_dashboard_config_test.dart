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
