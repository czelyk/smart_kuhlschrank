import 'dart:async';
import '../models/product_model.dart';

class ApiService {
  // Sahte ürün verileri
  final List<Map<String, dynamic>> _mockFridgeContents = [
    {
      "name": "Milch",
      "expiryDate": DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      "quantity": "1L",
      "category": "Molkereiprodukte"
    },
    {
      "name": "Eier",
      "expiryDate": DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      "quantity": "10 Stück",
      "category": "Grundnahrungsmittel"
    },
    {
      "name": "Käse",
      "expiryDate": DateTime.now().add(const Duration(days: 15)).toIso8601String(),
      "quantity": "200g",
      "category": "Molkereiprodukte"
    }
  ];

  // Orijinal fetchProducts metodunu sahte veri döndürecek şekilde güncelledik.
  Future<List<Product>> fetchProducts() async {
    // Bir ağ gecikmesini simüle etmek için 2 saniye bekleyin
    await Future.delayed(const Duration(seconds: 2));

    // Sahte veriyi Product nesnelerine dönüştürün
    return _mockFridgeContents.map((json) => Product.fromJson(json)).toList();

    // Gerçek API'ye geçiş yapmak istediğinizde bu satırların yorumunu kaldırın.
    /*
    final String baseUrl = "http://<ESP32 veya sunucu IP>/api";
    final response = await http.get(Uri.parse('$baseUrl/fridge/contents'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı!');
    }
    */
  }
}
