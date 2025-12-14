import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projekt/models/fridge_status_model.dart';
import '../models/shelf_model.dart';
import '../services/fridge_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FridgeService _fridgeService = FridgeService();

  // Dialog for editing shelf names (remains unchanged)
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

  /// Builds the new card to display fridge status, now with error handling.
  Widget _buildFridgeStatusCard() {
    return StreamBuilder<FridgeStatus>(
      stream: _fridgeService.getFridgeStatusStream(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;

        // --- DIAGNOSTIC: Explicitly handle errors ---
        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.red[100], // Red background for errors
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.error} (Status Card):',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Don't show anything if there is no data
        }

        final status = snapshot.data!;

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusIcon(icon: Icons.thermostat, value: '${status.temperature.toStringAsFixed(1)}°C', label: 'Sıcaklık'),
                _StatusIcon(icon: Icons.opacity, value: '${status.humidity.toStringAsFixed(1)}%', label: 'Nem'),
              ],
            ),
          ),
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
      body: Column(
        children: [
          // 1. The Fridge Status Card (now with error display)
          _buildFridgeStatusCard(),

          // 2. The existing list of shelves
          Expanded(
            child: StreamBuilder<List<Shelf>>(
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
          ),
        ],
      ),
    );
  }
}

/// A helper widget to display a status icon, value, and label.
class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatusIcon({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.teal, size: 30),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
