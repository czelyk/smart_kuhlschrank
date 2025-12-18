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

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'createdAt': Timestamp.now(),
    };
  }
}
