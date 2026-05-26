import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/unlock_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/qr/presentation/qr_scanner_page.dart';
import '../../features/orders/presentation/order_tracking_page.dart';
import '../../features/orders/presentation/order_queue_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/unlock', builder: (context, state) => UnlockPage()),
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
    GoRoute(path: '/qr-scanner', builder: (context, state) => QrScannerPage()),
    GoRoute(path: '/order-tracking', builder: (context, state) => OrderTrackingPage()),
    GoRoute(path: '/order-queue', builder: (context, state) => OrderQueuePage()),
  ]
);