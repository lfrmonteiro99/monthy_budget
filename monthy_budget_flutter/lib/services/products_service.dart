import '../exceptions/app_exceptions.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import 'log_service.dart';

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
    try {
      _cache = await _resolvedRepository.load();
      _loaded = true;
      return _cache;
    } catch (e, stack) {
      LogService.error(
        'Failed to load products',
        error: e,
        stackTrace: stack,
        category: 'service.products',
      );
      throw DataException('Failed to load products', e, stack);
    }
  }
}
