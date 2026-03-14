import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/info_icon_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

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
}
