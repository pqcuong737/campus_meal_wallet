import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/order_repository.dart';
import 'bloc/order_queue_bloc.dart';
import 'bloc/order_queue_event.dart';
import 'bloc/order_queue_state.dart';

class OrderQueuePage extends StatelessWidget {
  const OrderQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderQueueBloc(context.read<OrderRepository>()),
      child: const _OrderQueueView(),
    );
  }
}

class _OrderQueueView extends StatelessWidget {
  const _OrderQueueView();

  void placeOrder(BuildContext context) {
    context.read<OrderQueueBloc>().add(
      const OrderPlaced(itemName: 'Sample Item', quantity: 1),
    );
  }

  void sync(BuildContext context) {
    context.read<OrderQueueBloc>().add(const OrderQueueSyncRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderQueueBloc, OrderQueueState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Order Queue')),
        body: BlocBuilder<OrderQueueBloc, OrderQueueState>(
          builder: (context, state) {
            final isLoading =
                state.status == OrderQueueStatus.loading ||
                state.status == OrderQueueStatus.syncing;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _ConnectionStatusCard(isOnline: state.isOnline ?? true),
                  
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => placeOrder(context),
                      icon: const Icon(Icons.restaurant),
                      label: Text(isLoading ? 'Processing...' : 'Place Order'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => sync(context),
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Pending Orders'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pending Orders: ${state.pendingOrders.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: state.pendingOrders.isEmpty
                        ? const Center(child: Text('No pending orders'))
                        : ListView.separated(
                            itemCount: state.pendingOrders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final order = state.pendingOrders[index];
                              return ListTile(
                                title: Text(order.itemName),
                                subtitle: Text(
                                  'Qty: ${order.quantity}\nID: ${order.id}}}',
                                ),
                                trailing: const Chip(label: Text('Pending')),
                              );
                            },
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

class _ConnectionStatusCard extends StatelessWidget {
  final bool isOnline;

  const _ConnectionStatusCard({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.red;
    final icon = isOnline ? Icons.wifi : Icons.wifi_off;
    final text = isOnline ? 'Online' : 'Offline';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
      ),
    );
  }
}
