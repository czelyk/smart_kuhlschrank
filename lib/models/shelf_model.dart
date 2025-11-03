class Shelf {
  final String id;
  final String name;
  final String sensorId;

  Shelf({
    required this.id,
    required this.name,
    required this.sensorId,
  });

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      id: json['id'],
      name: json['name'],
      sensorId: json['sensor_id'],
    );
  }
}
