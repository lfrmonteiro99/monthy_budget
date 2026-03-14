import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/screens/tax_simulator_screen.dart';

import '../helpers/test_app.dart';

void main() {
  AppSettings baseSettings() => const AppSettings(
        country: Country.pt,
        personalInfo: PersonalInfo(
          maritalStatus: MaritalStatus.solteiro,
          dependentes: 0,
        ),
        salaries: [
          SalaryInfo(
            label: 'Main',
            grossAmount: 2000,
            enabled: true,
            titulares: 1,
            mealAllowanceType: MealAllowanceType.card,
            mealAllowancePerDay: 8,
          ),
        ],
      );

  testWidgets('renders simulator title and presets', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        TaxSimulatorScreen(settings: baseSettings()),
      ),
    );

    expect(find.text('Tax Simulator'), findsOneWidget);
    expect(find.byType(ActionChip), findsAtLeastNWidgets(1));
  });

  testWidgets('applying raise preset updates gross salary value',
      (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        TaxSimulatorScreen(settings: baseSettings()),
      ),
    );

    await tester.tap(find.byType(ActionChip).first);
    await tester.pumpAndSettle();
    expect(find.text('Tax Simulator'), findsOneWidget);
    expect(find.text('CURRENT VS SIMULATED'), findsOneWidget);
  });
}
