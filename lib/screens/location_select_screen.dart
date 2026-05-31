import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'inventory_screen.dart';

class LocationSelectScreen extends ConsumerWidget {
  const LocationSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Välj Lager'),
        centerTitle: true,
      ),
      body: locationsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return const Center(
              child:
                  Text('Inga lagerplatser än.\nTryck + för att lägga till ett'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Text(loc.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  subtitle: loc.address != null ? Text(loc.address!) : null,
                  trailing: const Icon(Icons.arrow_forward_ios),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fel: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nytt Lager'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Namn (t.ex. Malmö Lager)'),
            ),
            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(labelText: 'Adress (valfritt)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(firestoreServiceProvider)
                    .createLocation(name, addrCtrl.text.trim());
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
