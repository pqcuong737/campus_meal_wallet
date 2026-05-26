import 'package:equatable/equatable.dart';

import '../../data/models/pending_order.dart';

enum OrderQueueStatus {
  initial,
  loading,
  success,
  offlineQueue,
  syncing,
  failure,
}

class OrderQueueState extends Equatable {
  final OrderQueueStatus status;
  final List<PendingOrder> pendingOrders;
  final bool? isOnline;
  final String? message;

  const OrderQueueState({
    required this.status,
    required this.pendingOrders,
    required this.isOnline,
    this.message,
  });

  const OrderQueueState.initial()
      : status = OrderQueueStatus.initial,
        pendingOrders = const [],
        isOnline = true,
        message = null;

  OrderQueueState copyWith({
    OrderQueueStatus? status,
    List<PendingOrder>? pendingOrders,
    bool? isOnline,
    String? message,
  }) {
    return OrderQueueState(
      status: status ?? this.status,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      isOnline: isOnline ?? this.isOnline,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, pendingOrders, isOnline, message];
}