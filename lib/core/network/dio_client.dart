import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

class DioClient {
  final SecureStorageService secureStorage;
  
  late final Dio dio;

  DioClient(this.secureStorage) {
    dio = Dio(BaseOptions(
      baseUrl: 'https://mock-campus-api.local',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.getAccessToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();  // Handle unauthorized error, e.g., refresh token or redirect to login

          if (refreshed) {
            final retryResponse = await _retry(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }

        handler.next(error);
      }
    ));
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await secureStorage.getRefreshToken();

    if (refreshToken == null) {
      return false;
    }

    await Future.delayed(const Duration(seconds: 1));

    await secureStorage.saveTokens('new_dummy_access_token', refreshToken);

    return true;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await secureStorage.getAccessToken();

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}