import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single shelf in the smart fridge.
class Shelf {
  final String id;      // The document ID from Firestore (e.g., 'tomato', 'water').
  final String name;    // A user-friendly name for the shelf (e.g., 'Tomatoes').
  final double weight;  // The current weight on the shelf in kilograms.

  Shelf({required this.id, required this.name, required this.weight});

  /// Creates a Shelf instance from a Firestore document snapshot.
  factory Shelf.fromFirestore(DocumentSnapshot doc) {
    // Cast the document data to a Map.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper function to create a user-friendly name from the ID.
    String _getFriendlyName(String id) {
      switch (id) {
        case 'tomato':
          return 'Tomaten';
        case 'water':
          return 'Wasser';
        case 'cola':
          return 'Cola';
        default:
          return id[0].toUpperCase() + id.substring(1); // Capitalize as a fallback.
      }
    }

    return Shelf(
      id: doc.id,
      name: _getFriendlyName(doc.id), // Use the helper to get a nice name.
      // Get the 'weight' field, defaulting to 0.0 if it doesn't exist or is not a number.
      weight: (data['weight'] ?? 0.0).toDouble(),
    );
  }
}
