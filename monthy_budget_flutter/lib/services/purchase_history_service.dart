import '../exceptions/app_exceptions.dart';
import '../models/purchase_record.dart';
import '../repositories/shopping_repository.dart';
import 'log_service.dart';

class PurchaseHistoryService {
  PurchaseRepository? _repository;

  PurchaseHistoryService({PurchaseRepository? repository})
    : _repository = repository;

  PurchaseRepository get _resolvedRepository =>
      _repository ??= SupabasePurchaseRepository();

  Future<PurchaseHistory> load(String householdId) async {
    try {
      return await _resolvedRepository.load(householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to load purchase history',
        error: e,
        stackTrace: stack,
        category: 'service.purchase_history',
      );
      throw DataException('Failed to load purchase history', e, stack);
    }
  }

  Future<void> saveRecord(PurchaseRecord record, String householdId) async {
    try {
      await _resolvedRepository.saveRecord(record, householdId);
    } catch (e, stack) {
      LogService.error(
        'Failed to save purchase history record',
        error: e,
        stackTrace: stack,
        category: 'service.purchase_history',
      );
      throw DataException('Failed to save purchase history record', e, stack);
    }
  }
}
