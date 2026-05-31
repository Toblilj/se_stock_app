import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String id;
  final String name;
  final String? address;
  final DateTime? createdAt;

  Location({
    required this.id,
    required this.name,
    this.address,
    this.createdAt,
  });

  factory Location.fromMap(Map<String, dynamic> map, String id) {
    return Location(
      id: id,
      name: map['name'] ?? '',
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
