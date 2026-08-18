import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/screens/yearly_summary_screen.dart';
import 'package:monthly_management/services/yearly_summary_service.dart';

import '../helpers/test_app.dart';

void main() {
  // Predefined categories (raw keys) plus a custom category (stored display
  // name), so the test proves the screen translates the former and passes the
  // latter through verbatim.
  const report = YearlySummaryReport(
    year: 2025,
    totalIncome: 6000,
    totalExpenses: 3000,
    netSavings: 3000,
    categoryTotals: {
      'habitacao': 1200,
      'alimentacao': 800,
      'Férias': 300,
    },
    categoryTrends: {
      'habitacao': [100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0],
      'alimentacao': [66.7, 66.7, 66.7, 66.7, 66.7, 66.7, 66.7, 66.7, 66.7, 66.7, 66.7, 66.7],
      'Férias': [25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0],
    },
    bestMonth: '2025-01',
    worstMonth: '2025-03',
    bestMonthNet: 1500,
    worstMonthNet: -200,
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        const YearlySummaryScreen(report: report),
        controller: AppShellController(locale: const Locale('pt')),
      ),
    );
  }

  testWidgets('translates predefined category keys and keeps custom names',
      (tester) async {
    await pumpScreen(tester);

    // Predefined categories render their translated, accented names.
    expect(find.text('Habitação'), findsOneWidget);
    expect(find.text('Alimentação'), findsOneWidget);

    // Custom category renders the stored display name verbatim.
    expect(find.text('Férias'), findsOneWidget);

    // No raw internal key is ever shown to the user.
    expect(find.text('habitacao'), findsNothing);
    expect(find.text('alimentacao'), findsNothing);
  });

  testWidgets('renders accented pt-PT titles', (tester) async {
    await pumpScreen(tester);

    // "Poupança Líquida" appears twice: the hero eyebrow and the bottom KPI row.
    expect(find.text('Poupança Líquida'), findsNWidgets(2));
    expect(find.text('Taxa de poupança: 50.0%'), findsOneWidget);
    expect(find.text('Distribuição por Categoria'), findsOneWidget);
    expect(find.text('Melhor mês (2025-01)'), findsOneWidget);
    expect(find.text('Pior mês (2025-03)'), findsOneWidget);

    // The old unaccented strings must not be present.
    expect(find.text('Poupanca Liquida'), findsNothing);
    expect(find.text('Distribuicao por Categoria'), findsNothing);
  });
}
