import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shelf_model.dart';

/// A service that manages the data for the smart fridge.
class FridgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Provides a stream of all shelves from the 'platforms' collection in Firestore.
  ///
  /// This stream will automatically emit a new list of shelves whenever the data
  /// on Firestore changes.
  Stream<List<Shelf>> getShelvesStream() {
    return _db.collection('platforms').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Shelf.fromFirestore(doc))
          .where((shelf) => shelf != null) // Filter out any potential nulls
          .cast<Shelf>() // Ensure the list is of type List<Shelf>
          .toList();
    });
  }

  /// Updates the name of a shelf in Firestore.
  Future<void> updateShelfName(String shelfId, String newName) {
    return _db.collection('platforms').doc(shelfId).update({'name': newName});
  }
}
