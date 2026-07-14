import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://127.0.0.1:8000/api/';
const FlutterSecureStorage storage = FlutterSecureStorage();

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          try {
            final response = await Dio().post(
              '${baseUrl}auth/refresh/',
              data: {'refresh': refreshToken},
            );
            final newAccess = response.data['access'];
            final newRefresh = response.data['refresh'];
            await storage.write(key: 'access_token', value: newAccess);
            await storage.write(key: 'refresh_token', value: newRefresh);
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
            final retryResponse = await dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            await storage.deleteAll();
          }
        }
      }
      handler.next(error);
    },
  ));

  return dio;
}
