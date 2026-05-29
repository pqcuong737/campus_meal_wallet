import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_tracking_repository.dart';
import 'order_tracking_event.dart';
import 'order_tracking_state.dart';

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final OrderTrackingRepository repository;

  StreamSubscription<OrderStatus>? _subscription;

  String? _currentOrderId;

  OrderTrackingBloc(this.repository)
    : super(const OrderTrackingState.initial()) {
    on<OrderTrackingStarted>(_onStarted);
    on<OrderTrackingStatusReceived>(_onStatusReceived);
    on<OrderTrackingConnectionLost>(_onConnectionLost);
  }

  Future<void> _onStarted(
    OrderTrackingStarted event,
    Emitter<OrderTrackingState> emit,
  ) async {
    _currentOrderId = event.orderId;

    emit(
      state.copyWith(
        connectionStatus: OrderTrackingConnectionStatus.connecting,
      ),
    );

    await _subscription?.cancel();

    _subscription = repository
        .watchOrderStatus(event.orderId)
        .listen(
          (status) => add(OrderTrackingStatusReceived(_mapStatusLabel(status))),
          onError: (_) => add(const OrderTrackingConnectionLost()),
          onDone: () => add(const OrderTrackingStatusReceived('completed')),
        );

    emit(
      state.copyWith(connectionStatus: OrderTrackingConnectionStatus.connected),
    );
  }

  void _onStatusReceived(
    OrderTrackingStatusReceived event,
    Emitter<OrderTrackingState> emit,
  ) async {
    final isCompleted = event.statusLabel == 'completed';

    emit(
      state.copyWith(
        connectionStatus: isCompleted
            ? OrderTrackingConnectionStatus.completed
            : OrderTrackingConnectionStatus.connected,
        currentStatus: event.statusLabel,
      ),
    );
  }

  Future<void> _onConnectionLost(OrderTrackingConnectionLost event, Emitter<OrderTrackingState> emit) async {
    final nextAttempt = state.reconnectAttempts + 1; // Increment attempt count for backoff calculation

    emit(
      state.copyWith(
        connectionStatus: OrderTrackingConnectionStatus.disconnected,
        reconnectAttempts: nextAttempt,
      ),
    );

    final delaySeconds = _getBackoffSeconds(nextAttempt);

    await Future.delayed(Duration(seconds: delaySeconds));

    if (isClosed) return; // Bloc may have been closed during the delay :3

    if (_currentOrderId == null || _currentOrderId!.isEmpty) return; // No order to track

    add(OrderTrackingStarted(_currentOrderId!));
  }

  int _getBackoffSeconds(int attempt) {
    if (attempt <= 1) return 1;
    if (attempt == 2) return 2;
    return 4;
  }

  String _mapStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return 'Created';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}