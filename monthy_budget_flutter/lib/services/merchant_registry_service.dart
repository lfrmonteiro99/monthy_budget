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
  final AuthRepository _authRepository;
  final MerchantRepository _repository;

  MerchantRegistryService({
    AuthRepository? authRepository,
    MerchantRepository? repository,
  }) : _authRepository = authRepository ?? SupabaseAuthRepository(),
       _repository = repository ?? SupabaseMerchantRepository();

  Future<MerchantInfo?> lookup(String nif) async {
    final row = await _repository.lookup(nif);
    if (row == null) return null;
    return MerchantInfo.fromSupabase(row);
  }

  Future<void> confirm(String nif) {
    return _repository.confirm(nif);
  }

  Future<void> register({
    required String nif,
    required String name,
    String? chain,
    String category = 'outro',
  }) {
    return _repository.register(
      nif: nif,
      name: name,
      chain: chain,
      category: category,
      createdBy: _authRepository.currentUserId,
    );
  }
}
