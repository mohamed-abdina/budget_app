import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../services/debt_service.dart';

final debtServiceProvider = Provider((ref) => DebtService());

final debtListProvider = StateNotifierProvider<DebtListNotifier, AsyncValue<List<Debt>>>((ref) {
  return DebtListNotifier(ref.read(debtServiceProvider));
});

class DebtListNotifier extends StateNotifier<AsyncValue<List<Debt>>> {
  final DebtService _service;

  DebtListNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final debts = await _service.getDebts();
      state = AsyncValue.data(debts);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _service.createDebt(data);
    load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _service.updateDebt(id, data);
    load();
  }

  Future<void> delete(int id) async {
    await _service.deleteDebt(id);
    load();
  }
}

final debtPaymentsProvider = FutureProvider.family<List<DebtPayment>, int>((ref, debtId) async {
  final service = ref.read(debtServiceProvider);
  return service.getPayments(debtId);
});
