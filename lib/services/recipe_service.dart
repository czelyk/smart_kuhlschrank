import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_kuhlschrank/models/recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Helper class for search results (lightweight)
class MealSummary {
  final String id;
  final String name;
  final String? imageUrl;

  MealSummary({required this.id, required this.name, this.imageUrl});

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'],
      name: json['strMeal'],
      imageUrl: json['strMealThumb'],
    );
  }
}

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's recipes collection
  CollectionReference? _getRecipesCollection() {
    final User? user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('recipes');
  }

  // Add a new recipe
  Future<void> addRecipe(Recipe recipe) async {
    final collection = _getRecipesCollection();
    if (collection != null) {
      await collection.add(recipe.toMap());
    }
  }

  // Get recipes stream
  Stream<List<Recipe>> getRecipesStream() {
    final collection = _getRecipesCollection();
    if (collection == null) return Stream.value([]);
    
    return collection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }

  // Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    final collection = _getRecipesCollection();
    if (collection != null) {
      await collection.doc(recipeId).delete();
    }
  }

  // Search for recipes without saving
  Future<List<MealSummary>> searchRecipes({String? category, String? area}) async {
    try {
      String url = '';
      if (category != null && category.isNotEmpty) {
        url = 'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category';
      } else if (area != null && area.isNotEmpty) {
        url = 'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area';
      } else {
        return []; 
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> meals = data['meals'] ?? [];
        return meals.map((m) => MealSummary.fromJson(m)).toList();
      }
    } catch (e) {
      print('Error searching recipes: $e');
    }
    return [];
  }

  // --- NEW: Fetch Recipe Object from API (Returns Recipe instead of saving immediately) ---
  Future<Recipe?> fetchRecipeFromApi(String id) async {
    try {
      final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return _parseMealToRecipe(data['meals'][0]);
        }
      }
    } catch (e) {
      print('Error fetching meal details: $e');
    }
    return null;
  }

  // --- NEW: Fetch details for specific IDs and save them (Legacy support) ---
  Future<void> fetchAndSaveRecipesByIds(List<String> ids) async {
    for (String id in ids) {
      final recipe = await fetchRecipeFromApi(id);
      if (recipe != null) {
        await addRecipe(recipe);
      }
    }
  }

  Recipe _parseMealToRecipe(Map<String, dynamic> meal) {
    final String name = meal['strMeal'] ?? 'Unknown Recipe';
    final String instructions = meal['strInstructions'] ?? '';
    final String? imageUrl = meal['strMealThumb'];
    final String? category = meal['strCategory'];
    final String? area = meal['strArea'];

    final List<Ingredient> ingredients = [];

    for (int j = 1; j <= 20; j++) {
      final ingredientName = meal['strIngredient$j'];
      final measure = meal['strMeasure$j'];
      
      if (ingredientName != null && ingredientName.toString().trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredientName.toString().trim(),
          quantity: measure?.toString().trim() ?? '',
        ));
      }
    }

    return Recipe(
      id: meal['idMeal'] ?? '', // API ID'sini geçici olarak tutuyoruz
      name: name,
      ingredients: ingredients,
      instructions: instructions,
      imageUrl: imageUrl,
      category: category,
      area: area,
    );
  }

  // Helper function to save existing recipe
  Future<void> saveRecipeDirectly(Recipe recipe) async {
    await addRecipe(recipe);
  }
}
