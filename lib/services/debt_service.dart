import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/debt.dart';
import '../models/debt_payment.dart';

class DebtService {
  final Dio _dio = createDio();

  Future<List<Debt>> getDebts() async {
    final response = await _dio.get('debts/');
    return (response.data as List).map((e) => Debt.fromJson(e)).toList();
  }

  Future<Debt> createDebt(Map<String, dynamic> data) async {
    final response = await _dio.post('debts/', data: data);
    return Debt.fromJson(response.data);
  }

  Future<Debt> updateDebt(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('debts/$id/', data: data);
    return Debt.fromJson(response.data);
  }

  Future<void> deleteDebt(int id) async {
    await _dio.delete('debts/$id/');
  }

  Future<List<DebtPayment>> getPayments(int debtId) async {
    final response = await _dio.get('debts/$debtId/payments/');
    return (response.data as List).map((e) => DebtPayment.fromJson(e)).toList();
  }

  Future<DebtPayment> createPayment(int debtId, Map<String, dynamic> data) async {
    final response = await _dio.post('debts/$debtId/payments/', data: data);
    return DebtPayment.fromJson(response.data);
  }

  Future<void> deletePayment(int debtId, int paymentId) async {
    await _dio.delete('debts/$debtId/payments/$paymentId/');
  }
}
