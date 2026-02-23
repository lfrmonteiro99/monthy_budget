import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const OrcamentoMensalApp());
    await tester.pumpAndSettle();
    expect(find.text('Orcamento Mensal'), findsOneWidget);
  });
}
