import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String name;
  final String quantity;

  Ingredient({required this.name, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final String instructions;
  final String? imageUrl;
  final String? category;
  final String? area;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    this.category,
    this.area,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    var ingredientsList = data['ingredients'] as List<dynamic>? ?? [];
    List<Ingredient> ingredients = ingredientsList
        .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
        .toList();

    return Recipe(
      id: doc.id,
      name: data['name'] ?? '',
      ingredients: ingredients,
      instructions: data['instructions'] ?? '',
      imageUrl: data['imageUrl'],
      category: data['category'],
      area: data['area'],
    );
  }

  // Yeni eklenen fromMap metodu (SharedPreferences için)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    var ingredientsList = map['ingredients'] as List<dynamic>? ?? [];
    List<Ingredient> ingredients = ingredientsList
        .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
        .toList();

    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ingredients: ingredients,
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'],
      category: map['category'],
      area: map['area'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // id alanını da ekledim
      'name': name,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'imageUrl': imageUrl,
      'category': category,
      'area': area,
      'createdAt': Timestamp.now().millisecondsSinceEpoch, // Timestamp yerine int olarak
    };
  }
}
