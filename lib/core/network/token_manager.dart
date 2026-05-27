import '../storage/secure_storage_service.dart';

class TokenManager {
  final SecureStorageService _secureStorageService;

  bool _isRefreshing = false;
  Future<String?>? _refreshFuture;

  TokenManager(this._secureStorageService);

  Future<String?> getAccessToken() async {
    return await _secureStorageService.getAccessToken();
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorageService.getRefreshToken();
  }

  Future<String?> refreshAccessToken() async {
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture;
    }

    _isRefreshing = true;
    _refreshFuture = _doRefresh();

    return _refreshFuture!.whenComplete(() {
      _isRefreshing = false;
      _refreshFuture = null;
    });
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null) {
      return null;
    }

    await Future.delayed(const Duration(seconds: 700));

    final newAccessToken = 'mock_refreshed_access_token_${DateTime.now().toIso8601String()}';

    await _secureStorageService.saveTokens(newAccessToken, refreshToken);

    return newAccessToken;
  }

  Future<void> clearTokens() async {
    await _secureStorageService.clearTokens();
  }
}