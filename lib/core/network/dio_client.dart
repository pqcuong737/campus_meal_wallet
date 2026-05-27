import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'token_manager.dart';
import 'auth_interceptor.dart';

class DioClient {
  final SecureStorageService secureStorage;

  late final Dio dio;

  late final TokenManager tokenManager;

  DioClient(this.secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    tokenManager = TokenManager(secureStorage);

    dio.interceptors.add(AuthInterceptor(dio: dio, tokenManager: tokenManager));

    // shoubld be removed in production | mask sensitive data in logs
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}
