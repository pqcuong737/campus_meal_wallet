import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/order_repository.dart';
import 'order_queue_event.dart';
import 'order_queue_state.dart';

class OrderQueueBloc extends Bloc<OrderQueueEvent, OrderQueueState> {
  final OrderRepository repository;

  StreamSubscription? _connectivitySubscription;

  OrderQueueBloc(this.repository) : super(const OrderQueueState.initial()) {
    on<OrderPlaced>(_onOrderPlaced);
    on<OrderQueueSyncRequested>(_onSyncRequested);
    on<OrderQueueConnectivityChanged>(_onConnectivityChanged);

    _connectivitySubscription = repository.connectivityStream.listen((
      isOnline,
    ) {
      add(OrderQueueConnectivityChanged(isOnline));
    });
  }

  Future<void> _onOrderPlaced(
    OrderPlaced event,
    Emitter<OrderQueueState> emit,
  ) async {
    // Avoiding multiple press place order :3
    if (state.status == OrderQueueStatus.loading ||
        state.status == OrderQueueStatus.syncing) {
      return;
    }

    emit(state.copyWith(status: OrderQueueStatus.loading));

    try {
      final order = await repository.placeOrder(
        itemName: event.itemName,
        quantity: event.quantity,
      );

      if (isClosed) return; // Bloc may have been closed while placing order :))

      final pendingOrders = repository.getPendingOrders();

      emit(
        state.copyWith(
          status: order.synced
              ? OrderQueueStatus.success
              : OrderQueueStatus.offlineQueue,
          pendingOrders: pendingOrders,
          message: order.synced
              ? 'Order placed successfully'
              : 'Offline. Order saved to queue',
        ),
      );
    } catch (_) {
      // Bloc may have been closed during the error handling :))
      if (isClosed) return; 

      emit(
        state.copyWith(
          status: OrderQueueStatus.failure,
          message: 'Failed to place order',
        ),
      );
    }
  }

  Future<void> _onSyncRequested(
    OrderQueueSyncRequested event,
    Emitter<OrderQueueState> emit,
  ) async {
    // Avoid multiple syncs at the same time :3
    if (state.status == OrderQueueStatus.syncing) return;

    emit(state.copyWith(status: OrderQueueStatus.syncing));

    await repository.syncPendingOrders();

    // Bloc may have been closed while syncing :))
    if (isClosed) return;

    emit(
      state.copyWith(
        status: OrderQueueStatus.success,
        pendingOrders: repository.getPendingOrders(),
        message: 'Pending orders synced',
      ),
    );
  }

  Future<void> _onConnectivityChanged(
    OrderQueueConnectivityChanged event,
    Emitter<OrderQueueState> emit,
  ) async {
    if (isClosed) return; // Bloc may have been closed while handling connectivity change :))

    emit(
      state.copyWith(
        isOnline: event.isOnline,
        pendingOrders: repository.getPendingOrders(),
        message: event.isOnline ? 'Back online' : 'You are offline',
      ),
    );

    if (event.isOnline) {
      add(const OrderQueueSyncRequested());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
