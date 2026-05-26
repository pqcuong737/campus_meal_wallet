import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/order_tracking_repository.dart';
import 'bloc/order_tracking_bloc.dart';
import 'bloc/order_tracking_event.dart';
import 'bloc/order_tracking_state.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return BlocProvider(
    //   create: (_) =>
    //       OrderTrackingBloc(OrderTrackingRepository()),
    //   child: const _OrderTrackingView(),
    // );

    return BlocProvider(
      create: (_) =>
          OrderTrackingBloc(OrderTrackingRepository())
            ..add(const OrderTrackingStarted('mock_order_001')),
      child: const _OrderTrackingView(),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  const _OrderTrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
        builder: (context, state) {
          final isCompleted =
              state.connectionStatus == OrderTrackingConnectionStatus.completed;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _ConnectionBanner(state: state),
                const SizedBox(height: 16),

                Icon(
                  isCompleted ? Icons.check_circle : Icons.local_shipping,
                  size: 80,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),

                const SizedBox(height: 16),

                Text(
                  state.currentStatus,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your campus meal order is being updated in real-time.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                _StatusTimeline(currentStatus: state.currentStatus),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final OrderTrackingState state;

  const _ConnectionBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final status = state.connectionStatus;

    if (status == OrderTrackingConnectionStatus.connected) {
      return const _Banner(
        text: 'Realtime connected',
        icon: Icons.wifi,
        color: Colors.green,
      );
    }

    if (status == OrderTrackingConnectionStatus.disconnected) {
      return _Banner(
        text:
            'Disconnected. Reconnecting attempt ${state.reconnectAttempts}...}',
        icon: Icons.wifi_off,
        color: Colors.red,
      );
    }

    if (status == OrderTrackingConnectionStatus.connecting) {
      return const _Banner(
        text: 'Connecting ...',
        icon: Icons.sync,
        color: Colors.orange,
      );
    }

    if (status == OrderTrackingConnectionStatus.completed) {
      return const _Banner(
        text: 'Order completed',
        icon: Icons.check_circle,
        color: Colors.green,
      );
    }

    return const SizedBox.shrink();
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _Banner({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String currentStatus;

  const _StatusTimeline({required this.currentStatus});

  static const statuses = ['Created', 'Preparing', 'Delivering', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      children: [
        for (int i = 0; i < statuses.length; i++) ...[
          _TimelineItem(label: statuses[i], isActive: i <= currentIndex),
        ],
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const _TimelineItem({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isActive ? Colors.green : Colors.grey,
        ),

        const SizedBox(width: 8),

        Text(
          label,
          style: TextStyle(color: isActive ? Colors.black : Colors.grey),
        ),
      ],
    );
  }
}
