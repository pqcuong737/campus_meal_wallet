import 'package:dio/dio.dart';

import 'token_manager.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenManager tokenManager;

  AuthInterceptor({required this.dio, required this.tokenManager});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenManager.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['X-Request-Id'] = DateTime.now().millisecondsSinceEpoch.toString();

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['alreadyRetried'] == true;

    if (statusCode == 401 && !alreadyRetried) {
      try {
        final newToken = await tokenManager.refreshAccessToken();

        if (newToken == null) {
          await tokenManager.clearTokens();
          return handler.next(err);
        }

        final response = await _retryRequest(
          err.requestOptions,
          newToken,
        );

        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions, String newToken) async {
    final retryOptions = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
      extra: {
        ...requestOptions.extra,
        'retried': true,
      },
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
    );

    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: retryOptions,
    );
  }
}
