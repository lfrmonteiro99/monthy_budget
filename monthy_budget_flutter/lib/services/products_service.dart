import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductsService {
  final ProductRepository _repository;
  List<Product> _cache = [];
  bool _loaded = false;

  ProductsService({ProductRepository? repository})
    : _repository = repository ?? SupabaseProductRepository();

  Future<List<Product>> load() async {
    if (_loaded) return _cache;
    _cache = await _repository.load();
    _loaded = true;
    return _cache;
  }
}
