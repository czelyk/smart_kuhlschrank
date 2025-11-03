import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../widgets/product_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = apiService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mein Kühlschrank')),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else {
            final productsList = snapshot.data!;
            return ListView.builder(
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                return ProductTile(product: productsList[index]);
              },
            );
          }
        },
      ),
    );
  }
}
