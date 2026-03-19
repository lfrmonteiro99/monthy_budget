import '../exceptions/app_exceptions.dart';
import '../models/purchase_record.dart';
import '../repositories/shopping_repository.dart';

class PurchaseHistoryService {
  final PurchaseRepository _repository;

  PurchaseHistoryService({PurchaseRepository? repository})
    : _repository = repository ?? SupabasePurchaseRepository();

  Future<PurchaseHistory> load(String householdId) async {
    try {
      return await _repository.load(householdId);
    } catch (e, stack) {
      throw DataException('Failed to load purchase history', e, stack);
    }
  }

  Future<void> saveRecord(PurchaseRecord record, String householdId) async {
    try {
      await _repository.saveRecord(record, householdId);
    } catch (e, stack) {
      throw DataException('Failed to save purchase history record', e, stack);
    }
  }
}
