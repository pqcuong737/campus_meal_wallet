import 'package:dio/dio.dart';

import 'auth_paths.dart';
import 'token_manager.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenManager tokenManager;

  AuthInterceptor({
    required this.dio,
    required this.tokenManager,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding Authorization header for public paths :3
    if (AuthPaths.isPublicPath(options.path)) {
      return handler.next(options);
    }

    final token = await tokenManager.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add a unique request ID for better tracing in logs
    options.headers['X-Request-Id'] =
        DateTime.now().microsecondsSinceEpoch.toString();

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;
    // Retry only once / request
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    // Only attempt refresh if it's a 401, we haven't already retried => infinite loop prevention, and it's not a public path
    final shouldRefresh = statusCode == 401 &&
        !alreadyRetried &&
        !AuthPaths.isPublicPath(requestPath);

    if (!shouldRefresh) {
      return handler.next(err);
    }

    final newAccessToken = await tokenManager.refreshAccessToken();

    if (newAccessToken == null || newAccessToken.isEmpty) {
      await tokenManager.clearTokens();
      return handler.next(err);
    }

    try {
      final response = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );

      return handler.resolve(response);
    } catch (retryError) {
      return handler.next(err);
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final retryOptions = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
      extra: {
        ...requestOptions.extra,
        'retried': true,
      },
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: retryOptions,
    );
  }
}