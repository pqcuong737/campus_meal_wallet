import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'token_manager.dart';

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

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenManager: tokenManager,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final sanitizedHeaders = Map<String, dynamic>.from(options.headers);

          if (sanitizedHeaders.containsKey('Authorization')) {
            sanitizedHeaders['Authorization'] = 'Bearer ***';
          }

          debugLog(
            '[REQUEST] ${options.method} ${options.path} headers=$sanitizedHeaders',
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugLog(
            '[RESPONSE] ${response.statusCode} ${response.requestOptions.path}',
          );

          handler.next(response);
        },
        onError: (error, handler) {
          debugLog(
            '[ERROR] ${error.response?.statusCode} ${error.requestOptions.path}',
          );

          handler.next(error);
        },
      ),
    );
  }

  void debugLog(String message) {
    // mask sensitive info in logs, e.g. Authorization header, query params, etc. :3 for secret !shh :3
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}