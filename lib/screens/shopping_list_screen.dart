import 'package:flutter/material.dart';
import '../models/shopping_list_item.dart';
import '../services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListService _shoppingListService = ShoppingListService();
  final TextEditingController _itemController = TextEditingController();

  // Yeni ürün eklemek için bir diyalog penceresi gösterir.
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neues Produkt hinzufügen'), // Add New Item
          content: TextField(
            controller: _itemController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Produktname'), // Item Name
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _itemController.clear();
              },
              child: const Text('Abbrechen'), // Cancel
            ),
            TextButton(
              onPressed: () {
                if (_itemController.text.isNotEmpty) {
                  _shoppingListService.addItem(_itemController.text);
                  Navigator.of(context).pop();
                  _itemController.clear();
                }
              },
              child: const Text('Hinzufügen'), // Add
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'), // Shopping List
      ),
      body: StreamBuilder<List<ShoppingListItem>>(
        stream: _shoppingListService.getShoppingListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}')); // Error
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Ihre Einkaufsliste ist leer.', // Your shopping list is empty.
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
                    if (value != null) {
                      _shoppingListService.updateItemStatus(item.id, value);
                    }
                  },
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.isChecked ? Colors.grey : Colors.black,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _shoppingListService.deleteItem(item.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Produkt hinzufügen',
        child: const Icon(Icons.add),
      ),
    );
  }
}
