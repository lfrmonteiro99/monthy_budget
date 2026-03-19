import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductsService {
  ProductRepository? _repository;
  List<Product> _cache = [];
  bool _loaded = false;

  ProductsService({ProductRepository? repository})
    : _repository = repository;

  ProductRepository get _resolvedRepository =>
      _repository ??= SupabaseProductRepository();

  Future<List<Product>> load() async {
    if (_loaded) return _cache;
    _cache = await _resolvedRepository.load();
    _loaded = true;
    return _cache;
  }
}
