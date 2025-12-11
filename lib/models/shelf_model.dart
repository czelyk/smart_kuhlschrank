import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single shelf in the smart fridge.
class Shelf {
  final String id;      // The document ID from Firestore (e.g., 'platform1').
  final String name;    // A user-friendly name for the shelf (e.g., 'Platform 1').
  final double weight;  // The current weight on the shelf in kilograms.

  Shelf({required this.id, required this.name, required this.weight});

  /// Creates a Shelf instance from a Firestore document snapshot.
  factory Shelf.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      throw Exception("Shelf document does not exist or has no data.");
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String defaultName;
    switch (doc.id) {
      case 'platform1':
        defaultName = '1. Platform';
        break;
      case 'platform2':
        defaultName = '2. Platform';
        break;
      default:
        defaultName = 'İsimsiz Raf';
    }

    return Shelf(
      id: doc.id,
      name: data['name'] ?? defaultName,
      weight: (data['weight'] ?? 0.0).toDouble(),
    );
  }
}
