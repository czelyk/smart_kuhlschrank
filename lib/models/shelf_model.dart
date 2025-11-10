import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single shelf in the smart fridge.
class Shelf {
  final String id;      // The document ID from Firestore (e.g., 'bitburger').
  final String name;    // A user-friendly name for the shelf (e.g., 'Bitburger').
  final double weight;  // The current weight on the shelf in kilograms.

  Shelf({required this.id, required this.name, required this.weight});

  /// Creates a Shelf instance from a Firestore document snapshot.
  factory Shelf.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      throw Exception("Shelf document does not exist or has no data.");
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper function to create a user-friendly name from the ID.
    String _getFriendlyName(String id) {
      switch (id) {
        case 'bitburger':
          return 'Bitburger';
        case 'pulleken':
          return 'Pulleken';
        default:
          // Capitalize the ID as a fallback name.
          return id.isNotEmpty ? id[0].toUpperCase() + id.substring(1) : 'Unnamed';
      }
    }

    return Shelf(
      id: doc.id,
      name: _getFriendlyName(doc.id), // Use the helper to get a nice name.
      weight: (data['weight'] ?? 0.0).toDouble(),
    );
  }
}
