import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _client = Supabase.instance.client;

  Future<MerchantInfo?> lookup(String nif) async {
    final rows = await _client
        .from('merchant_nif_registry')
        .select()
        .eq('nif', nif)
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return MerchantInfo.fromSupabase(rows.first as Map<String, dynamic>);
  }

  Future<void> confirm(String nif) async {
    await _client.rpc(
      'increment_merchant_confirmed',
      params: {'merchant_nif': nif},
    );
  }

  Future<void> register({
    required String nif,
    required String name,
    String? chain,
    String category = 'outro',
  }) async {
    final userId = _client.auth.currentUser?.id;
    await _client.from('merchant_nif_registry').upsert({
      'nif': nif,
      'name': name,
      'chain': chain,
      'category': category,
      'confirmed_count': 1,
      'created_by': userId,
    });
  }
}
