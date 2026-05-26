class PendingOrder {
  final String id;
  final String itemName;
  final int quantity;
  final DateTime createdAt;
  final bool synced;

  const PendingOrder({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.createdAt,
    required this.synced,
  });

  PendingOrder copyWith({
    String? id,
    String? itemName,
    int? quantity,
    DateTime? createdAt,
    bool? synced,
  }) {
    return PendingOrder(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    return PendingOrder(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      synced: json['synced'] as bool,
    );
  }
}