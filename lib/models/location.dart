class Location {
  final String id;
  final String name;
  final String? address;

  Location({
    required this.id,
    required this.name,
    this.address,
  });

  factory Location.fromMap(Map<String, dynamic> map, String id) {
    return Location(
      id: id,
      name: map['name'] ?? '',
      address: map['address'],
    );
  }
}