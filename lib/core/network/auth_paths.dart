class AuthPaths {
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';

  static const publicPaths = [
    login,
    refresh,
  ];

  static bool isPublicPath(String path) {
    return publicPaths.any((publicPath) => path.contains(publicPath));
  }
}