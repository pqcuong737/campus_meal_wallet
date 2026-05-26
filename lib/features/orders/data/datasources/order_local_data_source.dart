import 'package:hive/hive.dart';

import '../models/pending_order.dart';

class OrderLocalDataSource {
  static const boxName = 'pending_orders';

  Box<Map> get _box => Hive.box<Map>(boxName);

  Future<void> savePendingOrder(PendingOrder order) async {
    await _box.put(order.id, order.toJson());
  }

  List<PendingOrder> getPendingOrders() {
    return _box.values
        .map((json) => PendingOrder.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> maskAsSynced(String id) async {
    final json = _box.get(id);

    if (json == null) return;

    final order = PendingOrder.fromJson(Map<String, dynamic>.from(json));
    final updated = order.copyWith(synced: true);

    await _box.put(id, updated.toJson());
  }

  Future<void> deletePendingOrder(String id) async {
    await _box.delete(id);
  }

  int get pendingCount => getPendingOrders().length;
}
