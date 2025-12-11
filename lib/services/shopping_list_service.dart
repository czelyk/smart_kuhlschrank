import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_list_item.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mevcut kullanıcının alışveriş listesi verilerini stream olarak döndürür.
  Stream<List<ShoppingListItem>> getShoppingListStream() {
    final User? user = _auth.currentUser;
    if (user == null) {
      // Kullanıcı giriş yapmamışsa boş bir stream döndür.
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shopping_list')
        .orderBy('name') // Alfabetik olarak sırala
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ShoppingListItem.fromFirestore(doc)).toList();
    });
  }

  // Alışveriş listesine yeni bir ürün ekler.
  Future<void> addItem(String itemName) async {
    final User? user = _auth.currentUser;
    if (user == null || itemName.trim().isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).collection('shopping_list').add({
      'name': itemName.trim(),
      'isChecked': false, // Yeni ürün varsayılan olarak işaretlenmemiş
    });
  }

  // Bir ürünün işaretlenme durumunu günceller.
  Future<void> updateItemStatus(String itemId, bool isChecked) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shopping_list')
        .doc(itemId)
        .update({'isChecked': isChecked});
  }

  // Listeden bir ürünü siler.
  Future<void> deleteItem(String itemId) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shopping_list')
        .doc(itemId)
        .delete();
  }
}
