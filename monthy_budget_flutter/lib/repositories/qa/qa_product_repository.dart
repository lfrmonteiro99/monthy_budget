import '../../models/product.dart';
import '../local/qa_local_store.dart';
import '../product_repository.dart';
import 'qa_collections.dart';

/// Products and the merchant registry are global tables in Supabase, so the QA
/// documents are stored under a shared pseudo-household and read via
/// [QaLocalStore.queryAll].
class QaProductRepository implements ProductRepository {
  QaProductRepository(this._store);

  final QaLocalStore _store;

  @override
  Future<List<Product>> load() async {
    final rows = await _store.queryAll(QaCollections.products);
    final products = rows.map(Product.fromJson).toList();
    products.sort((a, b) {
      final byCategory = a.category.compareTo(b.category);
      return byCategory != 0 ? byCategory : a.name.compareTo(b.name);
    });
    return products;
  }
}

class QaMerchantRepository implements MerchantRepository {
  QaMerchantRepository(this._store, {required String globalScope})
    : _scope = globalScope;

  final QaLocalStore _store;
  final String _scope;

  @override
  Future<Map<String, dynamic>?> lookup(String nif) {
    return _store.get(QaCollections.merchants, _scope, nif);
  }

  @override
  Future<void> confirm(String nif) async {
    final row = await lookup(nif);
    if (row == null) return;
    final count = (row['confirmed_count'] as num?)?.toInt() ?? 0;
    await _store.put(QaCollections.merchants, _scope, nif, {
      ...row,
      'confirmed_count': count + 1,
    });
  }

  @override
  Future<void> register({
    required String nif,
    required String name,
    String? chain,
    String category = 'outro',
    String? createdBy,
  }) {
    return _store.put(QaCollections.merchants, _scope, nif, {
      'nif': nif,
      'name': name,
      'chain': chain,
      'category': category,
      'confirmed_count': 1,
      'created_by': createdBy,
    });
  }
}
