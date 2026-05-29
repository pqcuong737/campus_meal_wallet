import 'package:uuid/uuid.dart';

import '../../../../core/network/connectivity_service.dart';
import '../datasources/order_local_data_source.dart';
import '../models/pending_order.dart';

class OrderRepository {
  final OrderLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  bool _isSyncing = false;

  OrderRepository({
    required this.localDataSource,
    required this.connectivityService,
  });

  Future<PendingOrder> placeOrder({
    required String itemName,
    required int quantity,
  }) async {
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
    if (_isSyncing) return; // guard against concurrent syncs

    _isSyncing = true;

    try {
      final online = await connectivityService.isOnline;

      if (!online) return;

      final pendingOrders = localDataSource.getPendingOrders();

      for (final order in pendingOrders) {
        try {
          await _submitToServer(order);
          await localDataSource.maskAsSynced(order.id);
        } catch (e) {
          // Log error, but continue with next order
        }
      }
    } finally {
      _isSyncing = false;
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
    // final dioClient = context.read<DioClient>();
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock API success. POST /orders with idempotency key = order.id
    // Sample:
    // await dioClient.post(
    //   '/orders',
    //   data: order.toJson(),
    //   options: Options(headers: {'Idempotency-Key': order.id}), // Ensures server treats retries as same order
    // );
  }
}
