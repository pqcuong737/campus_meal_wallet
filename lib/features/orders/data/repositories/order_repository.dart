import 'package:uuid/uuid.dart';

import '../../../../core/network/connectivity_service.dart';
import '../datasources/order_local_data_source.dart';
import '../models/pending_order.dart';

class OrderRepository {
  final OrderLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  OrderRepository({
    required this.localDataSource,
    required this.connectivityService,
  });

  Future<PendingOrder> placeOrder({required String itemName, required int quantity}) async {
    final order = PendingOrder(
      id: const Uuid().v4(),
      itemName: itemName,
      quantity: quantity,
      createdAt: DateTime.now(),
      synced: false,
    );

    final online = await connectivityService.isOnline;

    if (online) {
      await _submitToServer(order);
      final syncedOrder = order.copyWith(synced: true);
      await localDataSource.savePendingOrder(syncedOrder);
      return syncedOrder;
    }

    await localDataSource.savePendingOrder(order);
    return order;
  }

  Future<void> syncPendingOrders() async {
    final online = await connectivityService.isOnline;

    if (!online) return;

    final pendingOrders = localDataSource.getPendingOrders();

    for (final order in pendingOrders) {
      try {
        await _submitToServer(order);
        await localDataSource.maskAsSynced(order.id);
      } catch (e) {
        // keep it pending
      }
    }
  }

  List<PendingOrder> getPendingOrders() {
    return localDataSource.getPendingOrders();
  }

  Stream<bool> get connectivityStream {
    return connectivityService.onStatusChanged;
  }

  Future<void> _submitToServer(PendingOrder order) async {
    // Simulate network call
    await Future.delayed(const Duration(seconds: 1));
    // Mock API success. POST /orders with idempotency key = order.id 
  }
}