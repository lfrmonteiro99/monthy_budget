import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/product.dart';

void main() {
  test('Product.fromJson maps fields and converts avg_price to double', () {
    final product = Product.fromJson({
      'id': 'p1',
      'name': 'Milk',
      'category': 'dairy',
      'avg_price': 1,
      'unit': 'L',
    });

    expect(product.id, 'p1');
    expect(product.name, 'Milk');
    expect(product.category, 'dairy');
    expect(product.avgPrice, 1.0);
    expect(product.unit, 'L');
  });
}
