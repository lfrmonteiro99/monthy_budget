import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase_record.dart';

class PurchaseHistoryService {
  static const _key = 'purchase_history';

  Future<PurchaseHistory> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const PurchaseHistory();
    try {
      return PurchaseHistory.fromJsonString(raw);
    } catch (_) {
      return const PurchaseHistory();
    }
  }

  Future<void> saveAll(PurchaseHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, history.toJsonString());
  }
}
