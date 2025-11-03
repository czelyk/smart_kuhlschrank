import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/product_tile.dart';

class ContentScreen extends StatelessWidget {
  final List<Product> products;

  const ContentScreen({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inhalt')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductTile(product: products[index]);
        },
      ),
    );
  }
}
