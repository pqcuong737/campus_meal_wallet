import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../wallet/presentation/topt_card.dart';
import '../../../shared/widgets/dashboard_action_card.dart';
import 'api_test_button.dart';
import 'widgets/dashboard_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthLoggedOut());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: const Color(0xFFF7F8FA),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => logout(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              DashboardHeader(),

              ToptCard(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          DashboardActionCard(
                            icon: Icons.qr_code_scanner,
                            title: 'Fast Scan Meal Voucher',
                            subtitle: 'Validate student meal QR code',
                            onTap: () => context.push('/qr-scanner'),
                          ),

                          const SizedBox(height: 12),

                          DashboardActionCard(
                            icon: Icons.delivery_dining,
                            title: 'Track Meal Order',
                            subtitle: 'Realtime order status updates',
                            onTap: () => context.push('/order-tracking'),
                          ),

                          const SizedBox(height: 12),

                          DashboardActionCard(
                            icon: Icons.cloud_off,
                            title: 'Offline Order Queue',
                            subtitle: 'Place orders offline and sync later',
                            onTap: () => context.push('/order-queue'),
                          ),

                          const SizedBox(height: 12),

                          DashboardActionCard(
                            icon: Icons.restaurant_menu,
                            title: 'Browse Campus Menu',
                            subtitle: 'Order meals and drinks from cafeteria',
                            onTap: () => context.push('/menu'),
                          ),

                          const SizedBox(height: 24),

                          const ApiTestButton(),

                          const SizedBox(height: 24),
                        ]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
