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

  static const backgroundColor = Color(0xFFFFF7F7);
  static const borderColor = Color(0xFF2F2F2F);
  static const primaryGreen = Color(0xFF52C41A);
  static const primaryBlue = Color(0xFF1677FF);

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
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Home',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF303030),
            ),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => logout(context),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),

                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16),
                //   child: _WalletSummary(),
                // ),

                const SizedBox(height: 22),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionTitle(
                    title: 'Secure Transaction',
                    subtitle: 'Use OTP for wallet and voucher actions',
                  ),
                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _ToptCardShell(),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionTitle(
                    title: 'Campus Services',
                    subtitle: 'Ordering, QR voucher, realtime tracking',
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      DashboardActionCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'Browse Campus Menu',
                        subtitle: 'Order meals and drinks from cafeteria',
                        backgroundColor: const Color(0xFFEFFFF0),
                        iconColor: primaryGreen,
                        onTap: () => context.push('/menu'),
                      ),

                      const SizedBox(height: 14),

                      DashboardActionCard(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Fast Scan Meal Voucher',
                        subtitle: 'Validate student meal QR code',
                        backgroundColor: const Color(0xFFEAF8FF),
                        iconColor: primaryBlue,
                        onTap: () => context.push('/qr-scanner'),
                      ),

                      const SizedBox(height: 14),

                      DashboardActionCard(
                        icon: Icons.delivery_dining_rounded,
                        title: 'Track Meal Order',
                        subtitle: 'Realtime order status updates',
                        backgroundColor: const Color(0xFFFFF8E5),
                        iconColor: Colors.orange,
                        onTap: () => context.push('/order-tracking'),
                      ),

                      const SizedBox(height: 14),

                      DashboardActionCard(
                        icon: Icons.cloud_off_rounded,
                        title: 'Offline Order Queue',
                        subtitle: 'Place orders offline and sync later',
                        backgroundColor: const Color(0xFFF1F0FF),
                        iconColor: Colors.deepPurple,
                        onTap: () => context.push('/order-queue'),
                      ),

                      const SizedBox(height: 24),

                      const _SectionTitle(
                        title: 'Developer Demo',
                        subtitle: 'Dio interceptor and token refresh test',
                      ),

                      const SizedBox(height: 12),

                      const _ApiButtonShell(),

                      const SizedBox(height: 24),

                      const _DemoNoteCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToptCardShell extends StatelessWidget {
  const _ToptCardShell();

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 2.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const ToptCard(),
      ),
    );
  }
}

class _ApiButtonShell extends StatelessWidget {
  const _ApiButtonShell();

  @override
  Widget build(BuildContext context) {
    return const ApiTestButton();
  }
}

class _DemoNoteCard extends StatelessWidget {
  const _DemoNoteCard();

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF1677FF),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Demo covers secure storage, biometric unlock, TOTP, QR scanning, offline queue, realtime stream, and token refresh.',
              style: TextStyle(
                color: Color(0xFF303030),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF52C41A),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF303030),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}