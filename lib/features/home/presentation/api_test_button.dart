import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/dio_client.dart';

class ApiTestButton extends StatelessWidget {
  const ApiTestButton({super.key});

  Future<void> testApi(BuildContext context) async {
    final dioClient = context.read<DioClient>();

    try {
      await dioClient.dio.get('/users/1');

      if (!context.mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API request success'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API request failed — expected with mock baseUrl'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => testApi(context),
          icon: const Icon(Icons.api),
          label: const Text('Test Authenticated API'),
        ),
      ),
    );
  }
}