import 'package:equatable/equatable.dart';

abstract class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

class OrderTrackingStarted extends OrderTrackingEvent {
  final String orderId;

  const OrderTrackingStarted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderTrackingStatusReceived extends OrderTrackingEvent {
  final String statusLabel;

  const OrderTrackingStatusReceived(this.statusLabel);

  @override
  List<Object?> get props => [statusLabel];
}

class OrderTrackingConnectionLost extends OrderTrackingEvent {
  const OrderTrackingConnectionLost();
}