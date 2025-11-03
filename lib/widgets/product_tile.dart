import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: Icon(Icons.kitchen),
        title: Text('${product.name}'),
        subtitle: Text('${product.quantity} ${product.unit}'),
        trailing: Text(
          'Son: ${product.expiryDate.day}.${product.expiryDate.month}.${product.expiryDate.year}',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
