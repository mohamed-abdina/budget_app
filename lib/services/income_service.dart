import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/income.dart';
import '../models/category.dart';

class IncomeService {
  final Dio _dio = createDio();

  Future<List<Income>> getIncomes({int? category, String? search, int? month, int? year}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;

    final response = await _dio.get('income/', queryParameters: params);
    return (response.data as List).map((e) => Income.fromJson(e)).toList();
  }

  Future<Income> createIncome(Map<String, dynamic> data) async {
    final response = await _dio.post('income/', data: data);
    return Income.fromJson(response.data);
  }

  Future<Income> updateIncome(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('income/$id/', data: data);
    return Income.fromJson(response.data);
  }

  Future<void> deleteIncome(int id) async {
    await _dio.delete('income/$id/');
  }

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('income/categories/');
    return (response.data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await _dio.post('income/categories/', data: data);
    return Category.fromJson(response.data);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('income/categories/$id/', data: data);
    return Category.fromJson(response.data);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('income/categories/$id/');
  }
}
