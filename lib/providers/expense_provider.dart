import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider((ref) => ExpenseService());

final expenseListProvider = StateNotifierProvider<ExpenseListNotifier, AsyncValue<List<Expense>>>((ref) {
  return ExpenseListNotifier(ref.read(expenseServiceProvider));
});

final expenseCategoriesProvider = StateNotifierProvider<ExpenseCategoryNotifier, AsyncValue<List<Category>>>((ref) {
  return ExpenseCategoryNotifier(ref.read(expenseServiceProvider));
});

class ExpenseListNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseService _service;
  int? _category;
  String? _search;
  int? _month;
  int? _year;

  ExpenseListNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _service.getExpenses(
        category: _category,
        search: _search,
        month: _month,
        year: _year,
      );
      state = AsyncValue.data(expenses);
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
    await _service.createExpense(data);
    load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _service.updateExpense(id, data);
    load();
  }

  Future<void> delete(int id) async {
    await _service.deleteExpense(id);
    load();
  }
}

class ExpenseCategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final ExpenseService _service;

  ExpenseCategoryNotifier(this._service) : super(const AsyncValue.loading()) {
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
