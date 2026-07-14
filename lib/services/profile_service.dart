import 'package:dio/dio.dart';
import '../config/api.dart';

class ProfileService {
  final Dio _dio = createDio();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('auth/profile/');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('auth/profile/', data: data);
    return response.data;
  }
}
