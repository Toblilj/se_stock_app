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
}