import '../storage/secure_storage_service.dart';

class TokenManager {
  final SecureStorageService secureStorage;

  bool _isRefreshing = false;
  Future<String?>? _refreshFuture;

  TokenManager(this.secureStorage);

  Future<String?> getAccessToken() {
    return secureStorage.getAccessToken();
  }

  Future<String?> getRefreshToken() {
    return secureStorage.getRefreshToken();
  }

  Future<String?> refreshAccessToken() {
    // If a refresh is already in progress, return the existing future to prevent multiple simultaneous refreshes
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture!;
    }

    _isRefreshing = true;
    _refreshFuture = _doRefresh();

    return _refreshFuture!.whenComplete(() {
      _isRefreshing = false;
      _refreshFuture = null;
    });
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await secureStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await clearTokens();
      return null;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 700)); // My fault =)) when 700s before deadline :3

      final newAccessToken =
          'mock_refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}';

      await secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );

      return newAccessToken;
    } catch (_) {
      await clearTokens();
      return null;
    }
  }

  Future<void> clearTokens() {
    return secureStorage.clearTokens();
  }
}