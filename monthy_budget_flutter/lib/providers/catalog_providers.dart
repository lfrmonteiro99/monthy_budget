import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grocery_data.dart';
import '../models/product.dart';

/// Product catalog (#632 increment 6). Storage-only.
class ProductsNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => const [];
  void set(List<Product> products) => state = products;
}

final productsProvider =
    NotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);

/// Grocery price data (#632 increment 6). Storage-only.
class GroceryDataNotifier extends Notifier<GroceryData> {
  @override
  GroceryData build() => const GroceryData();
  void set(GroceryData data) => state = data;
}

final groceryDataProvider =
    NotifierProvider<GroceryDataNotifier, GroceryData>(GroceryDataNotifier.new);
