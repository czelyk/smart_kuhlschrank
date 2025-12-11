import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  void _showAddItemDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addNewItem),
          content: TextField(
            controller: _itemController,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.itemName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _itemController.clear();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (_itemController.text.isNotEmpty) {
                  _shoppingListService.addItem(_itemController.text);
                  Navigator.of(context).pop();
                  _itemController.clear();
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingList),
      ),
      body: StreamBuilder<List<ShoppingListItem>>(
        stream: _shoppingListService.getShoppingListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                l10n.yourShoppingListIsEmpty,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
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
        tooltip: l10n.addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
