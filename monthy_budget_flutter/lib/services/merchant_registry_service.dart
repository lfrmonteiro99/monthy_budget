import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';

class MerchantInfo {
  final String nif;
  final String name;
  final String? chain;
  final String category;

  const MerchantInfo({
    required this.nif,
    required this.name,
    this.chain,
    required this.category,
  });

  factory MerchantInfo.fromSupabase(Map<String, dynamic> row) {
    return MerchantInfo(
      nif: row['nif'] as String,
      name: row['name'] as String,
      chain: row['chain'] as String?,
      category: row['category'] as String? ?? 'outro',
    );
  }
}

class MerchantRegistryService {
  AuthRepository? _authRepository;
  MerchantRepository? _repository;

  MerchantRegistryService({
    AuthRepository? authRepository,
    MerchantRepository? repository,
  }) : _authRepository = authRepository,
       _repository = repository;

  AuthRepository get _resolvedAuthRepository =>
      _authRepository ??= SupabaseAuthRepository();

  MerchantRepository get _resolvedRepository =>
      _repository ??= SupabaseMerchantRepository();

  Future<MerchantInfo?> lookup(String nif) async {
    final row = await _resolvedRepository.lookup(nif);
    if (row == null) return null;
    return MerchantInfo.fromSupabase(row);
  }

  Future<void> confirm(String nif) {
    return _resolvedRepository.confirm(nif);
  }

  Future<void> register({
    required String nif,
    required String name,
    String? chain,
    String category = 'outro',
  }) {
    return _resolvedRepository.register(
      nif: nif,
      name: name,
      chain: chain,
      category: category,
      createdBy: _resolvedAuthRepository.currentUserId,
    );
  }
}
