import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shelf_model.dart';

class FridgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Provides a stream of shelves from the currently logged-in user's 'platforms' sub-collection.
  ///
  /// Returns an empty list stream if no user is logged in.
  Stream<List<Shelf>> getShelvesStream() {
    final User? user = _auth.currentUser;

    if (user == null) {
      // Return a stream of an empty list if the user is not logged in.
      return Stream.value([]);
    }

    // Path to the sub-collection: users/{userId}/platforms
    final collectionPath = _db.collection('users').doc(user.uid).collection('platforms');

    return collectionPath.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Shelf.fromFirestore(doc))
          .where((shelf) => shelf != null) // Filter out any potential nulls
          .cast<Shelf>()
          .toList();
    });
  }

  /// Updates the name of a shelf for the currently logged-in user.
  Future<void> updateShelfName(String shelfId, String newName) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      // Or throw an error, depending on desired behavior.
      return;
    }
    
    // Path to the document in the sub-collection: users/{userId}/platforms/{shelfId}
    final docPath = _db.collection('users').doc(user.uid).collection('platforms').doc(shelfId);

    await docPath.update({'name': newName});
  }
}
