import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import 'app.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/dio_client.dart';
import 'core/security/biometric_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/orders/data/datasources/order_local_data_source.dart';
import 'features/orders/data/repositories/order_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<Map>('pending_orders');

  const flutterSecureStorage = FlutterSecureStorage();

  final secureStorageService = SecureStorageService(flutterSecureStorage);
  final dioClient = DioClient(secureStorageService);

  final authRepository = AuthRepository(secureStorageService);

  final biometricService = BiometricService(LocalAuthentication());

  final connectivityService = ConnectivityService(Connectivity());

  final orderRepository = OrderRepository(
    localDataSource: OrderLocalDataSource(),
    connectivityService: connectivityService,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: biometricService),
        RepositoryProvider.value(value: orderRepository),
        RepositoryProvider.value(value: dioClient),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepository)..add(const AuthStarted()),
        child: const MyApp(),
      ),
    ),
  );
}