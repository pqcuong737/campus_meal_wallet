import 'package:flutter/foundation.dart';

enum OrderStatus {
  created,
  preparing,
  delivering,
  completed,
}

class OrderTrackingRepository {
  Stream<OrderStatus> watchOrderStatus(String orderId) async* {
    final statuses = [
      OrderStatus.created,
      OrderStatus.preparing,
      OrderStatus.delivering,
      OrderStatus.completed,
    ];

    for (final status in statuses) {
      await Future.delayed(const Duration(seconds: 5));
      if (kDebugMode) {
        print('Emitting status: $status');
      }

      yield status;
    }
  }
}