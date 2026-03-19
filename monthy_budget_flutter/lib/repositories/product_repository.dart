import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> load();
}

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _client;

  SupabaseProductRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Product>> load() async {
    final rows = await _client.from('products').select().order('category').order('name');
    return (rows as List<dynamic>)
        .map((row) => Product.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

abstract class MerchantRepository {
  Future<Map<String, dynamic>?> lookup(String nif);
  Future<void> confirm(String nif);
  Future<void> register({
    required String nif,
    required String name,
    String? chain,
    String category,
    String? createdBy,
  });
}

class SupabaseMerchantRepository implements MerchantRepository {
  final SupabaseClient _client;

  SupabaseMerchantRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> lookup(String nif) async {
    final rows = await _client
        .from('merchant_nif_registry')
        .select()
        .eq('nif', nif)
        .limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<void> confirm(String nif) {
    return _client.rpc(
      'increment_merchant_confirmed',
      params: {'merchant_nif': nif},
    );
  }

  @override
  Future<void> register({
    required String nif,
    required String name,
    String? chain,
    String category = 'outro',
    String? createdBy,
  }) {
    return _client.from('merchant_nif_registry').upsert({
      'nif': nif,
      'name': name,
      'chain': chain,
      'category': category,
      'confirmed_count': 1,
      'created_by': createdBy,
    });
  }
}
