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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Kühlschrank'),
        actions: [
          StreamBuilder<bool>(
            stream: _fridgeService.getDoorStatusStream(),
            builder: (context, snapshot) {
              bool isDoorOpen = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Icon(
                      isDoorOpen ? Icons.sensor_door_outlined : Icons.door_front_door_outlined,
                      color: isDoorOpen ? Colors.redAccent : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDoorOpen ? 'Offen' : 'Geschlossen',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        // The StreamBuilder now handles a nullable Shelf object.
        child: StreamBuilder<Shelf?>(
          stream: _fridgeService.getTomatoShelfStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Fehler beim Laden der Regal-Daten.');
            }
            // Check if data is not null. This is the crucial part.
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Tomaten-Regal nicht gefunden.');
            }

            final shelf = snapshot.data!;

            return Card(
              margin: const EdgeInsets.all(16),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.food_bank_outlined,
                      color: Colors.teal,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      shelf.name, // 'Tomaten'
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${shelf.weight.toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
