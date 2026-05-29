import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/firestore_service.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  final String locationId;
  final String locationName;

  const InventoryScreen({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _searchCtrl = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCsv,
            tooltip: 'Exportera som CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Sök produkt...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<InventoryItem>>(
              stream: _service.getInventory(widget.locationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];

                final filteredItems = items
                    .where((item) => item.name.toLowerCase().contains(searchQuery))
                    .toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'Inga produkter hittades\nTryck + för att lägga till',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'Senast: ${item.lastUpdated != null ? item.lastUpdated!.toString().substring(0, 16) : "Ny"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _updateQuantity(item, item.quantity - 1),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => _updateQuantity(item, item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ny produkt'),
      ),
    );
  }

  void _updateQuantity(InventoryItem item, int newQty) {
    if (newQty < 0) return;
    _service.addOrUpdateItem(widget.locationId, item.name, newQty);
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lägg till ny produkt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Produktnamn')),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Antal'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              if (name.isNotEmpty) {
                _service.addOrUpdateItem(widget.locationId, name, qty);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lägg till'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCsv() async {
    // Enkel export-funktion (kan förbättras senare)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export-funktion kommer snart...')),
    );
  }
}