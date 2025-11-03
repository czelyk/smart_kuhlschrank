import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  // Örnek veri
  final List<Map<String, String>> shoppingItems = const [
    {'name': 'Milch', 'amount': '1L'},
    {'name': 'Eier', 'amount': '6 Stk.'},
    {'name': 'Salat', 'amount': '1 kopf'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einkaufsliste')),
      body: ListView.builder(
        itemCount: shoppingItems.length,
        itemBuilder: (context, index) {
          final item = shoppingItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(item['name']!),
              subtitle: Text(item['amount']!),
              trailing: Checkbox(
                value: false,
                onChanged: (value) {
                  // İşaretleme işlemi yapılacak
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
