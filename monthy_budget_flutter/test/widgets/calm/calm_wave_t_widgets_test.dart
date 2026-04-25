import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget light(Widget child) => MaterialApp(
        theme: lightTheme(AppColorPalette.calm),
        home: Scaffold(body: child),
      );

  Widget dark(Widget child) => MaterialApp(
        theme: darkTheme(AppColorPalette.calm),
        home: Scaffold(body: child),
      );

  // ── CalmHeader ──────────────────────────────────────────────────────────

  testWidgets('CalmHeader renders (light)', (tester) async {
    await tester.pumpWidget(light(const CalmHeader(
      eyebrow: 'CASA SILVA',
      title: 'Abril 2026',
    )));
    expect(find.text('Abril 2026'), findsOneWidget);
    expect(find.text('CASA SILVA'), findsOneWidget);
  });

  testWidgets('CalmHeader renders (dark)', (tester) async {
    await tester.pumpWidget(dark(const CalmHeader(
      eyebrow: 'CASA SILVA',
      title: 'Abril 2026',
    )));
    expect(find.text('Abril 2026'), findsOneWidget);
  });

  testWidgets('CalmHeader tap fires callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(light(CalmHeader(
      eyebrow: 'CASA',
      title: 'Abril 2026',
      onTitleTap: () => fired = true,
    )));
    await tester.tap(find.text('Abril 2026'));
    expect(fired, isTrue);
  });

  // ── CalmAvatarBadge ─────────────────────────────────────────────────────

  testWidgets('CalmAvatarBadge renders initials', (tester) async {
    await tester.pumpWidget(light(const CalmAvatarBadge(initials: 'RS')));
    expect(find.text('RS'), findsOneWidget);
  });

  testWidgets('CalmAvatarBadge tap fires callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(light(CalmAvatarBadge(
      initials: 'RS',
      onTap: () => fired = true,
    )));
    await tester.tap(find.text('RS'));
    expect(fired, isTrue);
  });

  // ── CalmPageHeader ───────────────────────────────────────────────────────

  testWidgets('CalmPageHeader renders eyebrow and title', (tester) async {
    await tester.pumpWidget(light(const CalmPageHeader(
      eyebrow: 'SEMANA 16',
      title: 'Plano & compras',
      showBack: false,
    )));
    expect(find.text('SEMANA 16'), findsOneWidget);
    expect(find.text('Plano & compras'), findsOneWidget);
  });

  // ── CalmTile ─────────────────────────────────────────────────────────────

  testWidgets('CalmTile renders label and count', (tester) async {
    await tester.pumpWidget(light(const CalmTile(
      icon: Icons.shopping_cart,
      label: 'Lista',
      count: '14 itens',
    )));
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('14 itens'), findsOneWidget);
  });

  testWidgets('CalmTile tap fires callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(light(CalmTile(
      icon: Icons.shopping_cart,
      label: 'Lista',
      count: '14 itens',
      onTap: () => fired = true,
    )));
    await tester.tap(find.text('Lista'));
    expect(fired, isTrue);
  });

  // ── CalmMealRow ──────────────────────────────────────────────────────────

  testWidgets('CalmMealRow renders', (tester) async {
    await tester.pumpWidget(light(const CalmMealRow(
      eyebrow: 'Hoje · jantar',
      title: 'Massa com pesto',
      meta: '20min · €4,20',
    )));
    expect(find.text('Massa com pesto'), findsOneWidget);
    expect(find.text('20min · €4,20'), findsOneWidget);
  });

  testWidgets('CalmMealRow tap fires callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(light(CalmMealRow(
      eyebrow: 'Hoje · jantar',
      title: 'Massa com pesto',
      meta: '20min',
      onTap: () => fired = true,
    )));
    await tester.tap(find.text('Massa com pesto'));
    expect(fired, isTrue);
  });

  // ── CalmActionPill ───────────────────────────────────────────────────────

  testWidgets('CalmActionPill renders label', (tester) async {
    await tester.pumpWidget(light(CalmActionPill(
      label: 'Gerar',
      onTap: () {},
    )));
    expect(find.text('Gerar'), findsOneWidget);
  });

  testWidgets('CalmActionPill tap fires callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(light(CalmActionPill(
      label: 'Gerar',
      onTap: () => fired = true,
    )));
    await tester.tap(find.text('Gerar'));
    expect(fired, isTrue);
  });

  // ── CalmWeekGrid ─────────────────────────────────────────────────────────

  testWidgets('CalmWeekGrid renders', (tester) async {
    await tester.pumpWidget(light(CalmWeekGrid(
      days: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
      rows: const [
        CalmWeekGridRow(
          label: 'Almoço',
          cells: ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
        ),
      ],
    )));
    expect(find.text('Almoço'), findsOneWidget);
    expect(find.text('Seg'), findsOneWidget);
  });

  testWidgets('CalmWeekGrid cell tap fires callback', (tester) async {
    int? tappedRow, tappedDay;
    await tester.pumpWidget(light(CalmWeekGrid(
      days: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
      rows: const [
        CalmWeekGridRow(
          label: 'Almoço',
          cells: ['A', '', '', '', '', '', ''],
        ),
      ],
      onCellTap: (r, d) {
        tappedRow = r;
        tappedDay = d;
      },
    )));
    await tester.tap(find.text('A'));
    expect(tappedRow, 0);
    expect(tappedDay, 0);
  });

  // ── CalmKpiRow ───────────────────────────────────────────────────────────

  testWidgets('CalmKpiRow renders label and value', (tester) async {
    await tester.pumpWidget(light(
      const CalmKpiRow('Custo total', '€62,40'),
    ));
    expect(find.text('Custo total'), findsOneWidget);
    expect(find.text('€62,40'), findsOneWidget);
  });

  // ── CalmCreamPill ────────────────────────────────────────────────────────

  testWidgets('CalmCreamPill renders label', (tester) async {
    await tester.pumpWidget(light(
      const CalmCreamPill(label: 'Plano Plus'),
    ));
    expect(find.text('Plano Plus'), findsOneWidget);
  });

  // ── CalmSwatchRow ────────────────────────────────────────────────────────

  testWidgets('CalmSwatchRow renders swatches', (tester) async {
    await tester.pumpWidget(light(CalmSwatchRow(
      swatches: const [
        CalmSwatch('Calm', Colors.blue),
        CalmSwatch('Forest', Colors.green),
      ],
      selectedIndex: 0,
      onChanged: (_) {},
    )));
    expect(find.text('Calm'), findsOneWidget);
    expect(find.text('Forest'), findsOneWidget);
  });

  testWidgets('CalmSwatchRow tap fires onChanged', (tester) async {
    int? changed;
    await tester.pumpWidget(light(CalmSwatchRow(
      swatches: const [
        CalmSwatch('Calm', Colors.blue),
        CalmSwatch('Forest', Colors.green),
      ],
      selectedIndex: 0,
      onChanged: (i) => changed = i,
    )));
    await tester.tap(find.text('Forest'));
    expect(changed, 1);
  });

  // ── CalmBottomNav ────────────────────────────────────────────────────────

  testWidgets('CalmBottomNav renders', (tester) async {
    await tester.pumpWidget(light(CalmBottomNav(
      items: const [
        CalmBottomNavItem(icon: Icons.home, label: 'Início'),
        CalmBottomNavItem(icon: Icons.list, label: 'Plano'),
        CalmBottomNavItem(icon: Icons.bar_chart, label: 'Balanço'),
        CalmBottomNavItem(icon: Icons.settings, label: 'Definições'),
      ],
      selectedIndex: 0,
      onSelected: (_) {},
      onCenterPressed: () {},
    )));
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Plano'), findsOneWidget);
  });

  testWidgets('CalmBottomNav tap fires onSelected', (tester) async {
    int? selected;
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(AppColorPalette.calm),
      home: Scaffold(
        bottomNavigationBar: CalmBottomNav(
          items: const [
            CalmBottomNavItem(icon: Icons.home, label: 'Início'),
            CalmBottomNavItem(icon: Icons.list, label: 'Plano'),
            CalmBottomNavItem(icon: Icons.bar_chart, label: 'Balanço'),
            CalmBottomNavItem(icon: Icons.settings, label: 'Definições'),
          ],
          selectedIndex: 0,
          onSelected: (i) => selected = i,
          onCenterPressed: () {},
        ),
      ),
    ));
    await tester.tap(find.text('Plano'));
    expect(selected, 1);
  });

  testWidgets('CalmBottomNav center tap fires onCenterPressed', (tester) async {
    var fired = false;
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(AppColorPalette.calm),
      home: Scaffold(
        bottomNavigationBar: CalmBottomNav(
          items: const [
            CalmBottomNavItem(icon: Icons.home, label: 'Início'),
            CalmBottomNavItem(icon: Icons.list, label: 'Plano'),
            CalmBottomNavItem(icon: Icons.bar_chart, label: 'Balanço'),
            CalmBottomNavItem(icon: Icons.settings, label: 'Definições'),
          ],
          selectedIndex: 0,
          onSelected: (_) {},
          onCenterPressed: () => fired = true,
        ),
      ),
    ));
    // Center FAB is rendered via Icon(Icons.add)
    await tester.tap(find.byIcon(Icons.add));
    expect(fired, isTrue);
  });
}
