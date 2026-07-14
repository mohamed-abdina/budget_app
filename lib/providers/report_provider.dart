import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/report_service.dart';

final reportServiceProvider = Provider((ref) => ReportService());

final reportSummaryProvider = FutureProvider.family<Map<String, dynamic>, ({int month, int year})>((ref, params) async {
  final service = ref.read(reportServiceProvider);
  return service.getSummary(month: params.month, year: params.year);
});

final reportMonthlyProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, months) async {
  final service = ref.read(reportServiceProvider);
  return service.getMonthly(months: months);
});

final reportCategoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, ({int month, int year})>((ref, params) async {
  final service = ref.read(reportServiceProvider);
  return service.getCategories(month: params.month, year: params.year);
});
