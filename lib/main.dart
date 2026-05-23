import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app.dart';
import 'core/security/biometric_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flutterSecureStorage = FlutterSecureStorage();

  final secureStorageService = SecureStorageService(flutterSecureStorage);
  final authRepository = AuthRepository(secureStorageService);
  final authBloc = AuthBloc(authRepository)..add(const AuthStarted());
  final biometricService = BiometricService();

  runApp(
    RepositoryProvider.value(
      value: authRepository,
      child: RepositoryProvider.value(
        value: biometricService,
        child: BlocProvider.value(value: authBloc, child: const MyApp()),
      ),
    ),
  );
}
