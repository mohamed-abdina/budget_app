import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/income.dart';
import '../models/category.dart';
import '../services/income_service.dart';

final incomeServiceProvider = Provider((ref) => IncomeService());

final incomeListProvider = StateNotifierProvider<IncomeListNotifier, AsyncValue<List<Income>>>((ref) {
  return IncomeListNotifier(ref.read(incomeServiceProvider));
});

final incomeCategoriesProvider = StateNotifierProvider<IncomeCategoryNotifier, AsyncValue<List<Category>>>((ref) {
  return IncomeCategoryNotifier(ref.read(incomeServiceProvider));
});

class IncomeListNotifier extends StateNotifier<AsyncValue<List<Income>>> {
  final IncomeService _service;
  int? _category;
  String? _search;
  int? _month;
  int? _year;

  IncomeListNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final incomes = await _service.getIncomes(
        category: _category,
        search: _search,
        month: _month,
        year: _year,
      );
      state = AsyncValue.data(incomes);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setFilter({int? category, String? search, int? month, int? year}) {
    _category = category;
    _search = search;
    _month = month;
    _year = year;
    load();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _service.createIncome(data);
    load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _service.updateIncome(id, data);
    load();
  }

  Future<void> delete(int id) async {
    await _service.deleteIncome(id);
    load();
  }
}

class IncomeCategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final IncomeService _service;

  IncomeCategoryNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _service.getCategories();
      state = AsyncValue.data(categories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _service.createCategory(data);
    load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _service.updateCategory(id, data);
    load();
  }

  Future<void> delete(int id) async {
    await _service.deleteCategory(id);
    load();
  }
}
