import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firestore_service.dart';
import 'models/location.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final locationsProvider = StreamProvider<List<Location>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getLocations();
});

final currentLocationProvider = StateProvider<String?>((ref) => null);
