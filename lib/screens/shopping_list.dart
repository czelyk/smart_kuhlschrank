import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projekt/services/auth_service.dart';

// Represents a single item in the shopping list.
class ShoppingListItem {
  final String id;
  final String name;
  bool isChecked;

  ShoppingListItem({required this.id, required this.name, this.isChecked = false});

  // Creates a ShoppingListItem from a Firestore document.
  factory ShoppingListItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ShoppingListItem(
      id: doc.id,
      name: data['name'] ?? '',
      isChecked: data['isChecked'] ?? false,
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _textController = TextEditingController();

  // Gets the current user's shopping list collection.
  CollectionReference? _getShoppingListCollection() {
    final User? user = _authService.currentUser;
    if (user == null) {
      return null; // Should not happen if behind AuthGate
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('shopping_list');
  }

  // Gets the shopping list from Firestore as a stream.
  Stream<List<ShoppingListItem>> _getShoppingList() {
    final collection = _getShoppingListCollection();
    if (collection == null) {
      return Stream.value([]);
    }
    return collection.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ShoppingListItem.fromFirestore(doc)).toList();
    });
  }

  // Adds a new item to the shopping list.
  Future<void> _addItem(String name) async {
    final collection = _getShoppingListCollection();
    if (name.isNotEmpty && collection != null) {
      await collection.add({
        'name': name,
        'isChecked': false,
        'createdAt': Timestamp.now(), // For sorting
      });
      _textController.clear();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  // Deletes an item from the shopping list.
  Future<void> _deleteItem(String id) async {
    final collection = _getShoppingListCollection();
    if (collection != null) {
      await collection.doc(id).delete();
    }
  }

  // Toggles the checked state of an item.
  Future<void> _toggleChecked(ShoppingListItem item) async {
    final collection = _getShoppingListCollection();
    if (collection != null) {
      await collection.doc(item.id).update({
        'isChecked': !item.isChecked,
      });
    }
  }

  // Shows the dialog to add a new item.
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neuen Artikel hinzufügen'), // Add New Item
          content: TextField(
            controller: _textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Artikelname (z.B. Milch)'), // Item name (e.g., Milk)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'), // Cancel
            ),
            ElevatedButton(
              onPressed: () => _addItem(_textController.text),
              child: const Text('Hinzufügen'), // Add
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = _getShoppingListCollection();

    if (collection == null) {
      return const Scaffold(
        body: Center(
          child: Text('Bitte anmelden, um die Einkaufsliste zu sehen.'), // Please log in to see the shopping list.
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'), // Shopping List
      ),
      body: StreamBuilder<List<ShoppingListItem>>(
        stream: _getShoppingList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Deine Einkaufsliste ist leer.', // Your shopping list is empty.
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Checkbox(
                  value: item.isChecked,
                  onChanged: (bool? value) {
                    _toggleChecked(item);
                  },
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteItem(item.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Neuen Artikel hinzufügen', // Add New Item
        child: const Icon(Icons.add),
      ),
    );
  }
}
