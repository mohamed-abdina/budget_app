import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/auth.dart';

class AuthService {
  final Dio _dio = createDio();

  Future<AuthTokens> login(String email, String password) async {
    final response = await _dio.post('auth/login/', data: {
      'email': email,
      'password': password,
    });
    return AuthTokens.fromJson(response.data);
  }

  Future<void> register(String email, String password, String firstName) async {
    await _dio.post('auth/register/', data: {
      'email': email,
      'password': password,
      'first_name': firstName,
    });
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await storage.write(key: 'access_token', value: tokens.access);
    await storage.write(key: 'refresh_token', value: tokens.refresh);
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }
}
