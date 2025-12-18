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
}
