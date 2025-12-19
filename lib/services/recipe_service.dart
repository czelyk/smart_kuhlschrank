import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_kuhlschrank/models/recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Fetch random recipes from TheMealDB and save them to Firestore
  Future<void> fetchAndAddRandomRecipes(int count) async {
    for (int i = 0; i < count; i++) {
      try {
        final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            final meal = data['meals'][0];
            
            final String name = meal['strMeal'] ?? 'Unknown Recipe';
            final String instructions = meal['strInstructions'] ?? '';
            final List<Ingredient> ingredients = [];

            // TheMealDB provides up to 20 ingredients as separate fields
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

            final recipe = Recipe(
              id: '', // Firestore will generate the ID
              name: name, 
              ingredients: ingredients, 
              instructions: instructions
            );
            
            await addRecipe(recipe);
          }
        }
      } catch (e) {
        print('Error fetching recipe: $e');
      }
    }
  }
}
