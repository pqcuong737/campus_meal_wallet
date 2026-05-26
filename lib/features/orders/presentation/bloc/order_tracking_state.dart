import 'package:equatable/equatable.dart';

enum OrderTrackingConnectionStatus {
  initial,
  connecting,
  connected,
  disconnected,
  completed,
  failure,
}

class OrderTrackingState extends Equatable {
  final OrderTrackingConnectionStatus connectionStatus;
  final String currentStatus;
  final int reconnectAttempts;

  const OrderTrackingState({
    required this.connectionStatus,
    required this.currentStatus,
    required this.reconnectAttempts,
  });

  const OrderTrackingState.initial()
      : connectionStatus = OrderTrackingConnectionStatus.initial,
        currentStatus = 'Waiting',
        reconnectAttempts = 0;

  OrderTrackingState copyWith({
    OrderTrackingConnectionStatus? connectionStatus,
    String? currentStatus,
    int? reconnectAttempts,
  }) {
    return OrderTrackingState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentStatus: currentStatus ?? this.currentStatus,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
    );
  }

  @override
  List<Object?> get props => [connectionStatus, currentStatus, reconnectAttempts];
}