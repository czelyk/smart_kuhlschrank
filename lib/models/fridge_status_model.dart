import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class representing the status of the fridge, including temperature and humidity.
class FridgeStatus {
  final double temperature;
  final double humidity;

  FridgeStatus({required this.temperature, required this.humidity});

  /// Creates a [FridgeStatus] instance from a Firestore document.
  ///
  /// Returns null if the document data is invalid.
  factory FridgeStatus.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      // Return a default status if the document has no data
      return FridgeStatus(temperature: 0.0, humidity: 0.0);
    }

    return FridgeStatus(
      // Use ?? 0.0 to provide a default value if a field is missing.
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
