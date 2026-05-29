import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../orders/data/repositories/order_repository.dart';
import '../../orders/presentation/bloc/order_queue_bloc.dart';
import '../../orders/presentation/bloc/order_queue_event.dart';
import '../../orders/presentation/bloc/order_queue_state.dart';
import '../data/models/campus_menu_item.dart';
import '../data/repositories/menu_repository.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderQueueBloc(
        context.read<OrderRepository>(),
      ),
      child: const _MenuView(),
    );
  }
}

class _MenuView extends StatefulWidget {
  const _MenuView();

  @override
  State<_MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<_MenuView> {
  late final Future<List<CampusMenuItem>> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = context.read<MenuRepository>().getMenuItems();
  }

  void placeOrder(CampusMenuItem item) {
    if (!item.available) return;

    context.read<OrderQueueBloc>().add(
          OrderPlaced(
            itemName: item.name,
            quantity: 1,
          ),
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
        if (ModalRoute.of(context)?.isCurrent != true) return; // Avoid showing snackbar on background pages

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message!),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campus Menu'),
        ),
        body: FutureBuilder<List<CampusMenuItem>>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _MenuLoading();
            }

            if (snapshot.hasError) {
              return const _MenuError();
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return const _MenuEmpty();
            }

            return BlocBuilder<OrderQueueBloc, OrderQueueState>(
              buildWhen: (previous, current) {
                return previous.status != current.status ||
                    previous.isOnline != current.isOnline;
              },
              builder: (context, orderState) {
                final isOrdering =
                    orderState.status == OrderQueueStatus.loading ||
                    orderState.status == OrderQueueStatus.syncing;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ConnectionBanner(isOnline: orderState.isOnline!),

                    const SizedBox(height: 16),

                    const Text(
                      'Today\'s Menu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Order meals and drinks from campus cafeteria.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    for (final item in items) ...[
                      _MenuItemCard(
                        item: item,
                        isOrdering: isOrdering,
                        onOrder: () => placeOrder(item),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final bool isOnline;

  const _ConnectionBanner({
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.orange;
    final icon = isOnline ? Icons.wifi : Icons.wifi_off;
    final text = isOnline
        ? 'Online ordering available'
        : 'Offline mode: orders will be queued';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final CampusMenuItem item;
  final bool isOrdering;
  final VoidCallback onOrder;

  const _MenuItemCard({
    required this.item,
    required this.isOrdering,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !item.available || isOrdering;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Icon(_iconForCategory(item.category)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!item.available)
                  const Chip(label: Text('Sold out')),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              item.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Text(
                    formatVnd(item.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 96,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: disabled ? null : onOrder,
                    child: Text(isOrdering ? '...' : 'Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Drink':
        return Icons.local_cafe;
      case 'Snack':
        return Icons.bakery_dining;
      case 'Meal':
      default:
        return Icons.restaurant;
    }
  }

  String formatVnd(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()}đ';
  }
}

class _MenuLoading extends StatelessWidget {
  const _MenuLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Container(
          height: 112,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}

class _MenuEmpty extends StatelessWidget {
  const _MenuEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No menu items available'),
    );
  }
}

class _MenuError extends StatelessWidget {
  const _MenuError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Failed to load menu'),
    );
  }
}