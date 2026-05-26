import 'package:equatable/equatable.dart';

abstract class OrderQueueEvent extends Equatable {
  const OrderQueueEvent();

  @override
  List<Object?> get props => [];
}

class OrderPlaced extends OrderQueueEvent {
  final String itemName;
  final int quantity;

  const OrderPlaced({required this.itemName, required this.quantity});

  @override
  List<Object?> get props => [itemName, quantity];
}

class OrderQueueSyncRequested extends OrderQueueEvent {
  const OrderQueueSyncRequested();
}

class OrderQueueConnectivityChanged extends OrderQueueEvent {
  final bool isOnline;

  const OrderQueueConnectivityChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}