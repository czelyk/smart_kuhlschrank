import 'package:flutter/material.dart';
import 'package:smart_kuhlschrank/l10n/app_localizations.dart';
import 'package:smart_kuhlschrank/models/fridge_status_model.dart';
import '../models/shelf_model.dart';
import '../services/fridge_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FridgeService _fridgeService = FridgeService();

  // Kategori Listesi ve İkonları
  final Map<String, IconData> _categories = {
    'Vegetables': Icons.eco,
    'Fruits': Icons.apple,
    'Beverages': Icons.local_drink,
    'Meat & Fish': Icons.restaurant,
    'Dairy': Icons.local_pizza,
    'Snacks': Icons.cookie,
    'Staples': Icons.rice_bowl,
    'Other': Icons.inventory, // Raf için genel ikon
  };

  // Dialog for editing shelf name and category
  Future<void> _showEditDialog(BuildContext context, Shelf shelf) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController nameController = TextEditingController(text: shelf.name);
    final TextEditingController volumeController = TextEditingController(text: shelf.bottleVolume?.toString() ?? '0.5');

    String selectedCategory = _categories.containsKey(shelf.category) ? shelf.category : 'Other';
    String selectedContainerType = shelf.containerType ?? 'glass';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.editShelfName),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İsim Değiştirme
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.newShelfName,
                        prefixIcon: const Icon(Icons.edit),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Kategori Seçimi
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.keys.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(_categories[category], color: Colors.teal),
                              const SizedBox(width: 10),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),

                    if (selectedCategory == 'Beverages') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: volumeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.bottleVolume,
                          suffixText: "L",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedContainerType,
                        decoration: InputDecoration(
                          labelText: l10n.containerType,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'glass', child: Text(l10n.glass)),
                          DropdownMenuItem(value: 'plastic', child: Text(l10n.plastic)),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedContainerType = val!;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(l10n.save),
                  onPressed: () {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      double? volume;
                      String? containerType;

                      if (selectedCategory == 'Beverages') {
                         volume = double.tryParse(volumeController.text.replaceAll(',', '.'));
                         containerType = selectedContainerType;
                      }

                      _fridgeService.updateShelf(
                          shelf.id, 
                          newName, 
                          selectedCategory, 
                          bottleVolume: volume, 
                          containerType: containerType
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFridgeStatusCard() {
    return StreamBuilder<FridgeStatus>(
      stream: _fridgeService.getFridgeStatusStream(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;

        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.red[100],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('${l10n.error}: ${snapshot.error}'),
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

        if (!snapshot.hasData) return const SizedBox.shrink();

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
                _StatusIcon(icon: Icons.thermostat, value: '${status.temperature.toStringAsFixed(1)}°C', label: 'Temperature'),
                _StatusIcon(icon: Icons.opacity, value: '${status.humidity.toStringAsFixed(1)}%', label: 'Humidity'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightDisplay(Shelf shelf, AppLocalizations l10n) {
      if (shelf.category == 'Beverages' && shelf.bottleVolume != null && shelf.bottleVolume! > 0) {
          double singleWeight;
          // Estimation based on user input:
          // Glass: Empty weight approx 70% of volume (e.g. 0.5L -> 0.35kg empty + 0.5kg liquid = 0.85kg)
          // Total factor = 1.7
          if (shelf.containerType == 'glass') {
              singleWeight = shelf.bottleVolume! * 1.7; 
          } else {
              // Plastic: Empty weight approx 5% of volume.
              // Total factor = 1.05
              singleWeight = shelf.bottleVolume! * 1.05; 
          }
          
          if (singleWeight <= 0) return Text('${shelf.weight.toStringAsFixed(2)} kg');

          int count = (shelf.weight / singleWeight).round();
          return Text(
              '$count ${l10n.bottles}', 
              style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
          );
      }
      
      return Text(
          '${shelf.weight.toStringAsFixed(2)} kg',
          style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
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
          _buildFridgeStatusCard(),

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
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade50,
                          radius: 25,
                          child: Icon(
                            _categories[shelf.category] ?? Icons.inventory_2_outlined,
                            color: Colors.teal,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          shelf.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          shelf.category, 
                          style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w500)
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildWeightDisplay(shelf, l10n),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () => _showEditDialog(context, shelf),
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
