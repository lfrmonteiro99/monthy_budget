import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductsService {
  final _client = Supabase.instance.client;
  List<Product> _cache = [];
  bool _loaded = false;

  Future<List<Product>> load() async {
    if (_loaded) return _cache;
    final rows = await _client
        .from('products')
        .select()
        .order('category')
        .order('name');
    _cache = (rows as List<dynamic>)
        .map((r) => Product.fromJson(r as Map<String, dynamic>))
        .toList();
    _loaded = true;
    return _cache;
  }
}
