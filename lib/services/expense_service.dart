import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseService {
  final Dio _dio = createDio();

  Future<List<Expense>> getExpenses({int? category, String? search, int? month, int? year}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;

    final response = await _dio.get('expense/', queryParameters: params);
    return (response.data as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<Expense> createExpense(Map<String, dynamic> data) async {
    final response = await _dio.post('expense/', data: data);
    return Expense.fromJson(response.data);
  }

  Future<Expense> updateExpense(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('expense/$id/', data: data);
    return Expense.fromJson(response.data);
  }

  Future<void> deleteExpense(int id) async {
    await _dio.delete('expense/$id/');
  }

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('expense/categories/');
    return (response.data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await _dio.post('expense/categories/', data: data);
    return Category.fromJson(response.data);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('expense/categories/$id/', data: data);
    return Category.fromJson(response.data);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('expense/categories/$id/');
  }
}
