import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/pending_order.dart';
import '../data/repositories/order_repository.dart';
import 'bloc/order_queue_bloc.dart';
import 'bloc/order_queue_event.dart';
import 'bloc/order_queue_state.dart';

class OrderQueuePage extends StatelessWidget {
  const OrderQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderQueueBloc(context.read<OrderRepository>()),
      child: const _OrderQueueView(),
    );
  }
}

class _OrderQueueView extends StatelessWidget {
  const _OrderQueueView();

  static const backgroundColor = Color(0xFFFFF7F7);

  void placeOrder(BuildContext context) {
    context.read<OrderQueueBloc>().add(
          const OrderPlaced(
            itemName: 'Chicken Rice',
            quantity: 1,
          ),
        );
  }

  void sync(BuildContext context) {
    context.read<OrderQueueBloc>().add(
          const OrderQueueSyncRequested(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderQueueBloc, OrderQueueState>(
      listenWhen: (previous, current) {
        return previous.message != current.message &&
            current.message != null;
      },
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message!),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Offline Queue',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF303030),
            ),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
        body: BlocBuilder<OrderQueueBloc, OrderQueueState>(
          buildWhen: (previous, current) {
            return previous.status != current.status ||
                previous.pendingOrders != current.pendingOrders ||
                previous.isOnline != current.isOnline;
          },
          builder: (context, state) {
            final isLoading =
                state.status == OrderQueueStatus.loading ||
                state.status == OrderQueueStatus.syncing;

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _QueueHeader(
                          pendingCount: state.pendingOrders.length,
                        ),

                        const SizedBox(height: 18),

                        _ConnectionStatusCard(isOnline: state.isOnline!),

                        const SizedBox(height: 18),

                        _ActionPanel(
                          isLoading: isLoading,
                          status: state.status,
                          onPlaceOrder: () => placeOrder(context),
                          onSync: () => sync(context),
                        ),

                        const SizedBox(height: 24),

                        _SectionTitle(
                          title: 'Pending Orders',
                          subtitle:
                              '${state.pendingOrders.length} order(s) waiting for sync',
                        ),

                        const SizedBox(height: 12),

                        if (state.pendingOrders.isEmpty)
                          const _EmptyPendingOrders()
                        else
                          for (final order in state.pendingOrders) ...[
                            _PendingOrderCard(order: order),
                            const SizedBox(height: 12),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QueueHeader extends StatelessWidget {
  final int pendingCount;

  const _QueueHeader({
    required this.pendingCount,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FF),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
          width: 2.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(5, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -10,
            child: Icon(
              Icons.cloud_off_rounded,
              size: 92,
              color: Colors.deepPurple.withValues(alpha: 0.10),
            ),
          ),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 2.6,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: borderColor,
                      offset: Offset(3, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Colors.deepPurple,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Offline-first Ordering',
                      style: TextStyle(
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Order Queue',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pendingCount == 0
                          ? 'All orders are synced'
                          : '$pendingCount pending order(s)',
                      style: const TextStyle(
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final bool isOnline;

  const _ConnectionStatusCard({
    required this.isOnline,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? const Color(0xFF52C41A) : const Color(0xFFFF5A5F);
    final icon = isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final title = isOnline ? 'Online ordering available' : 'Offline mode';
    final subtitle = isOnline
        ? 'Pending orders can be synced now.'
        : 'New orders will be saved locally.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFEFFFF0) : const Color(0xFFFFEFF4),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final bool isLoading;
  final OrderQueueStatus status;
  final VoidCallback onPlaceOrder;
  final VoidCallback onSync;

  const _ActionPanel({
    required this.isLoading,
    required this.status,
    required this.onPlaceOrder,
    required this.onSync,
  });

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
      child: Column(
        children: [
          _CartoonButton(
            label: status == OrderQueueStatus.loading
                ? 'Placing order...'
                : 'Place Chicken Rice Order',
            icon: Icons.restaurant_rounded,
            backgroundColor: const Color(0xFF52C41A),
            foregroundColor: Colors.white,
            onPressed: isLoading ? null : onPlaceOrder,
          ),
          const SizedBox(height: 12),
          _CartoonButton(
            label: status == OrderQueueStatus.syncing
                ? 'Syncing...'
                : 'Sync Pending Orders',
            icon: Icons.sync_rounded,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF303030),
            onPressed: isLoading ? null : onSync,
          ),
        ],
      ),
    );
  }
}

class _CartoonButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _CartoonButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              disabled ? const Color(0xFFE9E9E9) : backgroundColor,
          foregroundColor:
              disabled ? const Color(0xFF888888) : foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: borderColor,
              width: 2.4,
            ),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
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

class _PendingOrderCard extends StatelessWidget {
  final PendingOrder order;

  const _PendingOrderCard({
    required this.order,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E5),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.itemName,
                  style: const TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${order.quantity}',
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${_shortId(order.id)}',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}...';
  }
}

class _EmptyPendingOrders extends StatelessWidget {
  const _EmptyPendingOrders();

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 54,
            color: Color(0xFF52C41A),
          ),
          SizedBox(height: 12),
          Text(
            'No pending orders',
            style: TextStyle(
              color: Color(0xFF303030),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'All offline orders have been synced.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}