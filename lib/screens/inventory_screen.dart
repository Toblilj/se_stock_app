import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert'; // för web

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportToCsv,
            tooltip: 'Exportera som CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Sök produkt...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
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

                final filtered = items
                    .where(
                        (item) => item.name.toLowerCase().contains(searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child:
                        Text('Inga produkter än.\nTryck + för att lägga till'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(item.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'Senast: ${item.lastUpdated != null ? item.lastUpdated!.toString().substring(0, 16) : "Ny"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () =>
                                  _updateQuantity(item, item.quantity - 1),
                            ),
                            Text('${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () =>
                                  _updateQuantity(item, item.quantity + 1),
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
        title: const Text('Lägg till produkt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Produktnamn')),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Antal'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
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
    try {
      final items = await _service.getInventory(widget.locationId).first;

      final csvData = [
        ['Produkt', 'Antal', 'Senast uppdaterad'],
        ...items.map((item) => [
              item.name,
              item.quantity.toString(),
              item.lastUpdated?.toString().substring(0, 16) ?? '',
            ]),
      ];

      final csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          "${widget.locationName.replaceAll(" ", "_")}_inventering_${DateTime.now().toString().substring(0, 10)}.csv";
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString);

      // Dela filen så man kan öppna den i Excel eller Gmail etc.
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Inventering ${widget.locationName} - ${DateTime.now().toString().substring(0, 16)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV-fil sparad och redo att delas!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kunde inte exportera: $e')),
        );
      }
    }
  }
}
