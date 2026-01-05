import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fridge_status_model.dart';
import '../models/shelf_model.dart';

class FridgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>>? _getStatusDocRef() {
    final User? user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('fridge_status').doc('current_status');
  }

  Stream<FridgeStatus> getFridgeStatusStream() {
    final docRef = _getStatusDocRef();
    if (docRef == null) {
      return Stream.value(FridgeStatus(temperature: 0.0, humidity: 0.0));
    }

    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        docRef.set({'temperature': 5.0, 'humidity': 45.0});
        return FridgeStatus(temperature: 5.0, humidity: 45.0);
      }
      return FridgeStatus.fromFirestore(snapshot);
    });
  }
  
  Stream<List<Shelf>> getShelvesStream() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    final collectionPath = _db.collection('users').doc(user.uid).collection('platforms');

    return collectionPath.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Shelf.fromFirestore(doc))
          .cast<Shelf>()
          .toList();
    });
  }

  // Hem ismi hem kategoriyi güncelleyen fonksiyon
  Future<void> updateShelf(String shelfId, String newName, String newCategory, {double? bottleVolume, String? containerType}) async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    
    final docPath = _db.collection('users').doc(user.uid).collection('platforms').doc(shelfId);

    Map<String, dynamic> data = {
      'name': newName,
      'category': newCategory,
    };

    if (newCategory == 'Beverages') {
       data['bottleVolume'] = bottleVolume;
       data['containerType'] = containerType;
    } else {
       // Eğer kategori içecek değilse bu alanları silebiliriz veya null yapabiliriz
       data['bottleVolume'] = FieldValue.delete();
       data['containerType'] = FieldValue.delete();
    }

    await docPath.update(data);
  }
}
