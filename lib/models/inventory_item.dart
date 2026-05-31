import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final DateTime? lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.lastUpdated,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItem(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }
}
