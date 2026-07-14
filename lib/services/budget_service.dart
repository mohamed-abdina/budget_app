import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/budget.dart';

class BudgetService {
  final Dio _dio = createDio();

  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;

    final response = await _dio.get('budgets/', queryParameters: params);
    return (response.data as List).map((e) => Budget.fromJson(e)).toList();
  }

  Future<Budget> createBudget(Map<String, dynamic> data) async {
    final response = await _dio.post('budgets/', data: data);
    return Budget.fromJson(response.data);
  }

  Future<Budget> updateBudget(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('budgets/$id/', data: data);
    return Budget.fromJson(response.data);
  }

  Future<void> deleteBudget(int id) async {
    await _dio.delete('budgets/$id/');
  }
}
