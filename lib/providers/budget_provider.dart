import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

final budgetServiceProvider = Provider((ref) => BudgetService());

final budgetListProvider = StateNotifierProvider<BudgetListNotifier, AsyncValue<List<Budget>>>((ref) {
  return BudgetListNotifier(ref.read(budgetServiceProvider));
});

class BudgetListNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final BudgetService _service;
  int? _month;
  int? _year;

  BudgetListNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final budgets = await _service.getBudgets(month: _month, year: _year);
      state = AsyncValue.data(budgets);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setFilter({int? month, int? year}) {
    _month = month;
    _year = year;
    load();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _service.createBudget(data);
    load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _service.updateBudget(id, data);
    load();
  }

  Future<void> delete(int id) async {
    await _service.deleteBudget(id);
    load();
  }
}
