import 'package:flutter/material.dart';
import '../models/location.dart';           // ← Detta saknades
import '../services/firestore_service.dart';
import 'inventory_screen.dart';

class LocationSelectScreen extends StatefulWidget {
  const LocationSelectScreen({super.key});

  @override
  State<LocationSelectScreen> createState() => _LocationSelectScreenState();
}

class _LocationSelectScreenState extends State<LocationSelectScreen> {
  final FirestoreService _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Välj Lager'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Location>>(
        stream: _service.getLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final locations = snapshot.data ?? [];

          if (locations.isEmpty) {
            return const Center(
              child: Text('Inga lagerplatser än.\nTryck + för att lägga till ett', 
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Text(loc.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  subtitle: loc.address != null ? Text(loc.address!) : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 28),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryScreen(
                          locationId: loc.id,
                          locationName: loc.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lägg till nytt lager'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Namn (t.ex. Malmö Lager)')),
            TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Adress (valfritt)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                _service.createLocation(nameCtrl.text.trim(), addrCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Skapa'),
          ),
        ],
      ),
    );
  }
}