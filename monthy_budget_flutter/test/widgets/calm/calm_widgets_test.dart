import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget wrap(Widget child) => MaterialApp(
        theme: lightTheme(),
        home: child,
      );

  testWidgets('CalmScaffold uses bg token for background', (tester) async {
    await tester.pumpWidget(wrap(const CalmScaffold(body: SizedBox())));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final ctx = tester.element(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.bg(ctx));
  });

  testWidgets('CalmScaffold has no AppBar when title is null', (tester) async {
    await tester.pumpWidget(wrap(const CalmScaffold(body: SizedBox())));
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('CalmScaffold shows AppBar when title is provided',
      (tester) async {
    await tester.pumpWidget(
        wrap(const CalmScaffold(title: 'Test', body: SizedBox())));
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('CalmPill renders label with its colour', (tester) async {
    const testColor = Colors.red;
    await tester.pumpWidget(
        wrap(const Scaffold(
            body: CalmPill(label: 'ok', color: testColor))));
    final text = tester.widget<Text>(find.text('ok'));
    expect(text.style?.color, testColor);
  });

  testWidgets('CalmHero renders eyebrow, amount, subtitle', (tester) async {
    await tester.pumpWidget(wrap(const Scaffold(
      body: CalmHero(
        eyebrow: 'ESTE MÊS',
        amount: '€1 247,30',
        subtitle: 'restam 12 dias',
      ),
    )));
    expect(find.text('ESTE MÊS'), findsOneWidget);
    expect(find.text('€1 247,30'), findsOneWidget);
    expect(find.text('restam 12 dias'), findsOneWidget);
  });

  testWidgets('CalmCard wraps child in padding 20 with onTap InkWell',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(Scaffold(
      body: CalmCard(
        onTap: () => tapped = true,
        child: const Text('content'),
      ),
    )));
    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}
