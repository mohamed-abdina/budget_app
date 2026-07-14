import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../providers/income_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';

// Dashboard-specific providers that don't affect list screens

final dashboardIncomesProvider = FutureProvider.family<List<Income>, ({int month, int year})>((ref, params) async {
  final service = ref.read(incomeServiceProvider);
  return service.getIncomes(month: params.month, year: params.year);
});

final dashboardExpensesProvider = FutureProvider.family<List<Expense>, ({int month, int year})>((ref, params) async {
  final service = ref.read(expenseServiceProvider);
  return service.getExpenses(month: params.month, year: params.year);
});

final dashboardBudgetsProvider = FutureProvider.family<List<Budget>, ({int month, int year})>((ref, params) async {
  final service = ref.read(budgetServiceProvider);
  return service.getBudgets(month: params.month, year: params.year);
});

// Last month data for comparison
final lastMonthIncomesProvider = FutureProvider.family<List<Income>, ({int month, int year})>((ref, params) async {
  final service = ref.read(incomeServiceProvider);
  return service.getIncomes(month: params.month, year: params.year);
});

final lastMonthExpensesProvider = FutureProvider.family<List<Expense>, ({int month, int year})>((ref, params) async {
  final service = ref.read(expenseServiceProvider);
  return service.getExpenses(month: params.month, year: params.year);
});
