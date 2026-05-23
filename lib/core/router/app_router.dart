import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/unlock_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/auth/presentation/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/unlock', builder: (context, state) => UnlockPage()),
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
  ]
);