import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/export_bottom_sheet.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('selecting PDF returns ExportFormat.pdf', (tester) async {
    ExportFormat? selected;

    await tester.pumpWidget(
      wrapWithTestApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selected = await showExportSheet(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pumpAndSettle();

    expect(selected, ExportFormat.pdf);
  });

  testWidgets('selecting CSV returns ExportFormat.csv', (tester) async {
    ExportFormat? selected;

    await tester.pumpWidget(
      wrapWithTestApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selected = await showExportSheet(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.table_chart));
    await tester.pumpAndSettle();

    expect(selected, ExportFormat.csv);
  });

  testWidgets('selecting Monthly Summary returns ExportFormat.monthlySummary',
      (tester) async {
    ExportFormat? selected;

    await tester.pumpWidget(
      wrapWithTestApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selected = await showExportSheet(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.summarize));
    await tester.pumpAndSettle();

    expect(selected, ExportFormat.monthlySummary);
  });
}

