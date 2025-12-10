import 'package:flutter/material.dart';
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
    final TextEditingController nameController =
        TextEditingController(text: shelf.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Raf Adını Düzenle'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Yeni raf adı"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Kaydet'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Kühlschrank'),
      ),
      body: StreamBuilder<List<Shelf>>(
        stream: _fridgeService.getShelvesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Regale gefunden.'));
          }

          final shelves = snapshot.data!;

          return ListView.builder(
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              // Get the image path for the current shelf.
              String? imagePath = _getImagePathForShelf(shelf.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  // Use Image.asset if a path is available, otherwise show a default icon.
                  leading: imagePath != null
                      ? Image.asset(
                          imagePath,
                          width: 40, // Set a fixed width for the image
                          height: 40, // Set a fixed height for the image
                          fit: BoxFit.contain, // Ensure the image fits well
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.teal,
                          size: 40,
                        ),
                  title: Text(
                    shelf.name, // 'Bitburger' or 'Pulleken'
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

  /// Helper function to return the correct image asset path for each shelf.
  String? _getImagePathForShelf(String shelfId) {
    switch (shelfId) {
      case 'bitburger':
        return 'assets/bitburger.jpg'; // Corrected from .png to .jpg
      case 'pulleken':
        return 'assets/pulleken.png';
      default:
        return null; // Return null if no specific image is found.
    }
  }
}
