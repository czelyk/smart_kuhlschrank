import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shelf_model.dart';

/// A service that manages the data for the smart fridge.
class FridgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Provides a stream of data for the 'tomato' shelf from Firestore.
  ///
  /// This stream listens to the 'platforms/tomato' document and emits a new
  /// Shelf object. If the document doesn't exist, it emits null.
  Stream<Shelf?> getTomatoShelfStream() { // Returns a nullable Shelf
    return _db.collection('platforms').doc('tomato').snapshots().map((snapshot) {
      if (snapshot.exists) {
        // If the document exists, create a Shelf object from it.
        return Shelf.fromFirestore(snapshot);
      } else {
        // If the document does not exist, emit null to be handled by the UI.
        return null;
      }
    });
  }

  /// Provides a stream of the door status from the 'fridge_status' collection.
  Stream<bool> getDoorStatusStream() {
    return _db.collection('fridge_status').doc('door').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['is_open'] as bool? ?? false;
      } else {
        return false;
      }
    });
  }
}
