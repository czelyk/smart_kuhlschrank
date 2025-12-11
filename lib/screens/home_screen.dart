import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/shelf_model.dart';
import '../services/fridge_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FridgeService _fridgeService = FridgeService();

  Future<void> _showEditNameDialog(BuildContext context, Shelf shelf) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController nameController =
        TextEditingController(text: shelf.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.editShelfName),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: l10n.newShelfName),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.save),
              onPressed: () {
                final newName = nameController.text;
                if (newName.isNotEmpty) {
                  _fridgeService.updateShelfName(shelf.id, newName);
                  Navigator.of(context).pop();
                }
              },
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
        title: Text(l10n.myFridge),
      ),
      body: StreamBuilder<List<Shelf>>(
        stream: _fridgeService.getShelvesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noShelvesFound));
          }

          final shelves = snapshot.data!;

          return ListView.builder(
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.teal,
                    size: 40,
                  ),
                  title: Text(
                    shelf.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${shelf.weight.toStringAsFixed(2)} kg',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditNameDialog(context, shelf),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
