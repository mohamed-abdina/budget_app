import 'package:dio/dio.dart';
import '../config/api.dart';

class ReportService {
  final Dio _dio = createDio();

  Future<Map<String, dynamic>> getSummary({int? month, int? year}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;

    final response = await _dio.get('reports/summary/', queryParameters: params);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getMonthly({int months = 6}) async {
    final response = await _dio.get('reports/monthly/', queryParameters: {'months': months});
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getCategories({int? month, int? year}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;

    final response = await _dio.get('reports/categories/', queryParameters: params);
    return List<Map<String, dynamic>>.from(response.data);
  }
}
