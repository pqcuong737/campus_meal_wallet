import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/biometric_service.dart';
import 'bloc/auth_bloc.dart';
// import 'bloc/auth_state.dart';
import 'bloc/auth_event.dart';

class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  bool isChecking = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> unlock() async {
    setState(() {
      isChecking = true;
      errorMessage = null;
    });

    final biometricService = context.read<BiometricService>();
    final success = await biometricService.authenticate();

    if (!mounted) return;

    setState(() {
      isChecking = false;
    });

    if (success) {
      context.go('/home');
    } else {
      setState(() {
        errorMessage = "Authentication failed. Please try again.";
      });
    }
  }

  void logout() {
    context.read<AuthBloc>().add(const AuthLoggedOut());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64),
          const SizedBox(height: 16),
          const Text('Unlock campus wallet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please authenticate to access your wallet', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          if (isChecking) const CircularProgressIndicator(),
          if (errorMessage != null) ...[
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isChecking ? null : unlock,
              child: const Text('Unlock')
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: isChecking ? null : logout, child: const Text('Logout')),
        ]
      ),
    ));
  }
}
