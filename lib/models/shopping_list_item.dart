import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final bool isChecked;

  ShoppingListItem({required this.id, required this.name, required this.isChecked});

  // Firestore'dan gelen veriyi ShoppingListItem objesine dönüştürür.
  factory ShoppingListItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShoppingListItem(
      id: doc.id,
      name: data['name'] ?? '',
      isChecked: data['isChecked'] ?? false,
    );
  }

  // Objeyi Firestore'a yazmak için Map'e dönüştürür.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isChecked': isChecked,
    };
  }
}
