import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';
import '../models/inventory_item.dart';

class FirestoreService {
  final Map<String, List<InventoryItem>> _inventoryData = {};
  static const String _storageKey = 'se_stock_inventory';

  // Ladda data från telefonens lagring
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      decoded.forEach((locationId, itemsJson) {
        _inventoryData[locationId] = (itemsJson as List)
            .map((item) => InventoryItem(
                  id: item['id'],
                  name: item['name'],
                  quantity: item['quantity'],
                  lastUpdated: item['lastUpdated'] != null 
                      ? DateTime.parse(item['lastUpdated']) 
                      : null,
                ))
            .toList();
      });
    }
  }

  // Spara data till telefonen
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = {};
    _inventoryData.forEach((key, items) {
      toSave[key] = items.map((item) => {
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'lastUpdated': item.lastUpdated?.toIso8601String(),
      }).toList();
    });
    await prefs.setString(_storageKey, json.encode(toSave));
  }

  Stream<List<Location>> getLocations() async* {
    yield [
      Location(id: 'malmo', name: 'Malmö Lager'),
      Location(id: 'helsingborg', name: 'Helsingborg Lager'),
      Location(id: 'goteborg', name: 'Göteborg Lager'),
    ];
  }

  Stream<List<InventoryItem>> getInventory(String locationId) async* {
    await loadData();
    _inventoryData.putIfAbsent(locationId, () => []);
    yield _inventoryData[locationId]!;
  }

  Future<void> addOrUpdateItem(String locationId, String name, int quantity) async {
    _inventoryData.putIfAbsent(locationId, () => []);
    final items = _inventoryData[locationId]!;

    final existingIndex = items.indexWhere((item) => item.name == name);
    if (existingIndex != -1) {
      items[existingIndex] = InventoryItem(
        id: items[existingIndex].id,
        name: name,
        quantity: quantity,
        lastUpdated: DateTime.now(),
      );
    } else {
      items.add(InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        quantity: quantity,
        lastUpdated: DateTime.now(),
      ));
    }
    await saveData();
  }

  Future<void> createLocation(String name, String? address) async {
    print('Nytt lager skapat: $name');
  }
}