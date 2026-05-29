import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_tokens.dart';

class AuthRepository {
  final SecureStorageService _secureStorageService;

  AuthRepository(this._secureStorageService);

  Future<AuthTokens> login({
    required String studentId,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful login and token retrieval
    final tokens = AuthTokens(
      accessToken: 'dummy_access_token',
      refreshToken: 'dummy_refresh_token',
    );

    // Save tokens securely
    await _secureStorageService.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  Future<bool> hasValidSession() async {
    final accessToken = await _secureStorageService.getAccessToken();
    // final refreshToken = await _secureStorageService.getRefreshToken();

    return accessToken != null && accessToken.isNotEmpty;
  }

  Future<void> logout() async {
    await _secureStorageService.clearTokens();
  }
}
