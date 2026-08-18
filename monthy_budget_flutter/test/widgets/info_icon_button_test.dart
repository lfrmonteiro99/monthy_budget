import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/widgets/info_icon_button.dart';

Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    locale: locale,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders info icon', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'Test Title', body: 'Test body text'),
    ));
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('opens bottom sheet on tap', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'Test Title', body: 'Test body text'),
    ));
    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test body text'), findsOneWidget);
  });

  testWidgets('bottom sheet has close button that dismisses', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'T', body: 'B'),
    ));
    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsNothing);
  });

  testWidgets('semantics label is translated in pt locale', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'ORÇAMENTO VS REAL', body: 'B'),
      locale: const Locale('pt'),
    ));
    final semantics = tester.getSemantics(find.byType(InfoIconButton));
    expect(semantics.label, 'Mais informação sobre ORÇAMENTO VS REAL');
    expect(semantics.label, isNot(contains('More info about')));
  });

  testWidgets('semantics label is translated in fr locale', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'BUDGET VS RÉEL', body: 'B'),
      locale: const Locale('fr'),
    ));
    final semantics = tester.getSemantics(find.byType(InfoIconButton));
    expect(semantics.label, "Plus d'informations sur BUDGET VS RÉEL");
  });

  testWidgets('semantics label is translated in es locale', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'PRESUPUESTO VS REAL', body: 'B'),
      locale: const Locale('es'),
    ));
    final semantics = tester.getSemantics(find.byType(InfoIconButton));
    expect(semantics.label, 'Más información sobre PRESUPUESTO VS REAL');
  });

  testWidgets('semantics label stays in English for en locale', (tester) async {
    await tester.pumpWidget(wrap(
      const InfoIconButton(title: 'BUDGET VS ACTUAL', body: 'B'),
      locale: const Locale('en'),
    ));
    final semantics = tester.getSemantics(find.byType(InfoIconButton));
    expect(semantics.label, 'More info about BUDGET VS ACTUAL');
  });
}
