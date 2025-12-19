import 'package:flutter/material.dart';
import 'package:smart_kuhlschrank/models/recipe_model.dart';
import 'package:smart_kuhlschrank/services/recipe_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  bool _isLoadingWebRecipes = false;
  
  // Track expanded recipes using a set of IDs
  final Set<String> _expandedRecipeIds = {}; 

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddRecipeDialog(),
    );
  }

  Future<void> _fetchRandomRecipes(BuildContext context) async {
    setState(() {
      _isLoadingWebRecipes = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _recipeService.fetchAndAddRandomRecipes(5); // Fetch 5 random recipes
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.recipesAddedSuccessfully)),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
      );
    } finally {
      setState(() {
        _isLoadingWebRecipes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipes),
        actions: [
          if (_isLoadingWebRecipes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: l10n.fetchRandomRecipes,
              onPressed: () => _fetchRandomRecipes(context),
            ),
        ],
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: _recipeService.getRecipesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noRecipesFound));
          }

          final recipes = snapshot.data!;

          return ListView.builder(
            itemCount: recipes.length,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80), // Add padding at bottom to avoid FAB overlap when not hidden
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final isExpanded = _expandedRecipeIds.contains(recipe.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  key: PageStorageKey(recipe.id), // Preserve state
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      if (expanded) {
                        _expandedRecipeIds.add(recipe.id);
                      } else {
                        _expandedRecipeIds.remove(recipe.id);
                      }
                    });
                  },
                  title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.ingredients, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...recipe.ingredients.map((i) => Text('• ${i.name} (${i.quantity})')),
                          const SizedBox(height: 16),
                          Text(l10n.instructions, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(recipe.instructions),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _recipeService.deleteRecipe(recipe.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _expandedRecipeIds.isEmpty 
        ? FloatingActionButton(
            onPressed: () => _showAddRecipeDialog(context),
            child: const Icon(Icons.add),
          )
        : null, // Hide FAB when any item is expanded
    );
  }
}

class AddRecipeDialog extends StatefulWidget {
  const AddRecipeDialog({Key? key}) : super(key: key);

  @override
  State<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<Ingredient> _ingredients = [];
  
  final _ingredientNameController = TextEditingController();
  final _ingredientQtyController = TextEditingController();

  final RecipeService _recipeService = RecipeService();

  void _addIngredient() {
    if (_ingredientNameController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient(
          name: _ingredientNameController.text,
          quantity: _ingredientQtyController.text,
        ));
        _ingredientNameController.clear();
        _ingredientQtyController.clear();
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate() && _ingredients.isNotEmpty) {
      final recipe = Recipe(
        id: '', // Generated by Firestore
        name: _nameController.text,
        ingredients: _ingredients,
        instructions: _instructionsController.text,
      );
      _recipeService.addRecipe(recipe);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addRecipe),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.recipeName),
                  validator: (value) => value!.isEmpty ? l10n.pleaseEnterRecipeName : null,
                ),
                const SizedBox(height: 16),
                Text(l10n.ingredients, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _ingredientNameController,
                        decoration: InputDecoration(labelText: l10n.ingredientName),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ingredientQtyController,
                        decoration: InputDecoration(labelText: l10n.quantity),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.teal),
                      onPressed: _addIngredient,
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];
                    return ListTile(
                      dense: true,
                      title: Text('${ingredient.name} (${ingredient.quantity})'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                if (_ingredients.isEmpty)
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(l10n.pleaseAddIngredients, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(labelText: l10n.instructions),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? l10n.pleaseEnterInstructions : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _saveRecipe,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
