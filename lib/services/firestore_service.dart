import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location.dart';
import '../models/inventory_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hämta alla lagerplatser
  Stream<List<Location>> getLocations() {
    return _db.collection('locations').orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Location.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Hämta inventering för ett lager (realtid)
  Stream<List<InventoryItem>> getInventory(String locationId) {
    return _db
        .collection('inventories')
        .doc(locationId)
        .collection('items')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Lägg till eller uppdatera produkt
  Future<void> addOrUpdateItem(
      String locationId, String name, int quantity) async {
    final ref =
        _db.collection('inventories').doc(locationId).collection('items');
    final query = await ref.where('name', isEqualTo: name).get();

    if (query.docs.isNotEmpty) {
      await ref.doc(query.docs.first.id).update({
        'quantity': quantity,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.add({
        'name': name,
        'quantity': quantity,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Skapa nytt lager
  Future<void> createLocation(String name, String? address) async {
    await _db.collection('locations').add({
      'name': name,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
