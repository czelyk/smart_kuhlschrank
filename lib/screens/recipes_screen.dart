import 'package:flutter/material.dart';
import 'package:smart_kuhlschrank/models/recipe_model.dart';
import 'package:smart_kuhlschrank/services/recipe_service.dart';
import 'package:smart_kuhlschrank/l10n/app_localizations.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import 'package:smart_kuhlschrank/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  final GoogleTranslator _translator = GoogleTranslator();
  SharedPreferences? _prefs;

  final List<String> _categories = [
    'Beef', 'Breakfast', 'Chicken', 'Dessert', 'Goat', 'Lamb', 'Miscellaneous',
    'Pasta', 'Pork', 'Seafood', 'Side', 'Starter', 'Vegan', 'Vegetarian'
  ];

  final List<String> _areas = [
    'American', 'British', 'Canadian', 'Chinese', 'Dutch', 'Egyptian', 'French',
    'Greek', 'Indian', 'Irish', 'Italian', 'Jamaican', 'Japanese', 'Kenyan',
    'Malaysian', 'Mexican', 'Moroccan', 'Polish', 'Portuguese', 'Russian', 
    'Spanish', 'Thai', 'Tunisian', 'Turkish', 'Vietnamese'
  ];
  
  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing SharedPreferences: $e");
    }
  }

  // --- Helper Methods ---
  String _getCategoryDisplay(AppLocalizations l10n, String category) {
    switch (category) {
      case 'Beef': return l10n.catBeef;
      case 'Breakfast': return l10n.catBreakfast;
      case 'Chicken': return l10n.catChicken;
      case 'Dessert': return l10n.catDessert;
      case 'Goat': return l10n.catGoat;
      case 'Lamb': return l10n.catLamb;
      case 'Miscellaneous': return l10n.catMiscellaneous;
      case 'Pasta': return l10n.catPasta;
      case 'Pork': return l10n.catPork;
      case 'Seafood': return l10n.catSeafood;
      case 'Side': return l10n.catSide;
      case 'Starter': return l10n.catStarter;
      case 'Vegan': return l10n.catVegan;
      case 'Vegetarian': return l10n.catVegetarian;
      default: return category;
    }
  }

  String _getAreaDisplay(AppLocalizations l10n, String area) {
    switch (area) {
      case 'American': return l10n.areaAmerican;
      case 'British': return l10n.areaBritish;
      case 'Canadian': return l10n.areaCanadian;
      case 'Chinese': return l10n.areaChinese;
      case 'Dutch': return l10n.areaDutch;
      case 'Egyptian': return l10n.areaEgyptian;
      case 'French': return l10n.areaFrench;
      case 'Greek': return l10n.areaGreek;
      case 'Indian': return l10n.areaIndian;
      case 'Irish': return l10n.areaIrish;
      case 'Italian': return l10n.areaItalian;
      case 'Jamaican': return l10n.areaJamaican;
      case 'Japanese': return l10n.areaJapanese;
      case 'Kenyan': return l10n.areaKenyan;
      case 'Malaysian': return l10n.areaMalaysian;
      case 'Mexican': return l10n.areaMexican;
      case 'Moroccan': return l10n.areaMoroccan;
      case 'Polish': return l10n.areaPolish;
      case 'Portuguese': return l10n.areaPortuguese;
      case 'Russian': return l10n.areaRussian;
      case 'Spanish': return l10n.areaSpanish;
      case 'Thai': return l10n.areaThai;
      case 'Tunisian': return l10n.areaTunisian;
      case 'Turkish': return l10n.areaTurkish;
      case 'Vietnamese': return l10n.areaVietnamese;
      default: return area;
    }
  }

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddRecipeDialog(),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    String? selectedCategory;
    String? selectedArea;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(l10n.fetchRandomRecipes),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.cuisine, 
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: selectedArea,
                      items: _areas.map((area) {
                        return DropdownMenuItem(value: area, child: Text(_getAreaDisplay(l10n, area)));
                      }).toList(),
                      onChanged: (value) => setStateDialog(() => selectedArea = value),
                      hint: Text(l10n.selectCuisine),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.category, 
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: selectedCategory,
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(_getCategoryDisplay(l10n, cat)));
                      }).toList(),
                      onChanged: (value) => setStateDialog(() => selectedCategory = value),
                      hint: Text(l10n.selectCategory),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSearchResultsDialog(context, selectedCategory, selectedArea);
                  },
                  child: Text(l10n.search),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSearchResultsDialog(BuildContext context, String? category, String? area) async {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final results = await _recipeService.searchRecipes(category: category, area: area);
      if (mounted) Navigator.of(context).pop(); 

      if (results.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noResultsFound)));
        return;
      }

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => SearchResultsSelectionDialog(
            results: results, 
            prefs: _prefs,
            translator: _translator,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // We pass these down to cards so they don't have to look them up repeatedly
    final localeProvider = Provider.of<LocaleProvider>(context);
    final String currentLang = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipes),
        actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.fetchRandomRecipes,
              onPressed: () => _showFilterDialog(context),
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
            // Optimization: Cache extent helps with smoother scrolling
            cacheExtent: 500, 
            padding: const EdgeInsets.only(bottom: 80), 
            itemBuilder: (context, index) {
              final originalRecipe = recipes[index];
              
              // Use a dedicated StatefulWidget for each card for better performance
              return RecipeCard(
                key: ValueKey(originalRecipe.id), // Important for performance
                originalRecipe: originalRecipe,
                currentLang: currentLang,
                prefs: _prefs,
                l10n: l10n,
                onDelete: () => _recipeService.deleteRecipe(originalRecipe.id),
                getAreaDisplay: (area) => _getAreaDisplay(l10n, area),
                getCategoryDisplay: (cat) => _getCategoryDisplay(l10n, cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- OPTIMIZED RECIPE CARD ---
// This widget handles its own translation logic and state, preventing full list rebuilds.
class RecipeCard extends StatefulWidget {
  final Recipe originalRecipe;
  final String currentLang;
  final SharedPreferences? prefs;
  final AppLocalizations l10n;
  final VoidCallback onDelete;
  final String Function(String) getAreaDisplay;
  final String Function(String) getCategoryDisplay;

  const RecipeCard({
    Key? key,
    required this.originalRecipe,
    required this.currentLang,
    required this.prefs,
    required this.l10n,
    required this.onDelete,
    required this.getAreaDisplay,
    required this.getCategoryDisplay,
  }) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  late Future<Recipe> _recipeFuture;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  @override
  void didUpdateWidget(RecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if language or recipe ID changes
    if (oldWidget.currentLang != widget.currentLang || 
        oldWidget.originalRecipe.id != widget.originalRecipe.id) {
      _loadRecipe();
    }
  }

  void _loadRecipe() {
    _recipeFuture = _getTranslatedRecipe(widget.originalRecipe, widget.currentLang);
  }

  Future<Recipe> _getTranslatedRecipe(Recipe originalRecipe, String targetLang) async {
    if (targetLang == 'en' || originalRecipe.id.isEmpty) return originalRecipe; 
    
    final cacheKey = 'recipe_trans_${originalRecipe.id}_$targetLang';

    // Check Disk Cache (It should be there if added via new method)
    if (widget.prefs != null) {
      final cachedString = widget.prefs!.getString(cacheKey);
      if (cachedString != null) {
        try {
          final Map<String, dynamic> recipeMap = jsonDecode(cachedString);
          return Recipe.fromMap(recipeMap);
        } catch (e) {
          print("Error decoding cached recipe: $e");
        }
      }
    }
    // Fallback to original if translation is missing (prevents crashes)
    return originalRecipe; 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe>(
      future: _recipeFuture,
      initialData: widget.originalRecipe,
      builder: (context, snapshot) {
        final recipe = snapshot.data ?? widget.originalRecipe;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            key: PageStorageKey(recipe.id),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
               setState(() {
                 _isExpanded = expanded;
               });
            },
            title: Row(
              children: [
                // Cached Network Image for Performance
                if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                        memCacheWidth: 150, // Downsample image to save memory
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.teal),
                  ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: [
                          if (recipe.area != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.getAreaDisplay(recipe.area!),
                                style: TextStyle(fontSize: 10, color: Colors.orange.shade900),
                              ),
                            ),
                          if (recipe.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.getCategoryDisplay(recipe.category!),
                                style: TextStyle(fontSize: 10, color: Colors.green.shade900),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              // Content is only built when expanded
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.l10n.ingredients, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map((i) => Text('• ${i.name} (${i.quantity})')),
                      const SizedBox(height: 16),
                      Text(widget.l10n.instructions, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(recipe.instructions),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: widget.onDelete,
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
  }
}

class SearchResultsSelectionDialog extends StatefulWidget {
  final List<MealSummary> results;
  final SharedPreferences? prefs;
  final GoogleTranslator translator;

  const SearchResultsSelectionDialog({
    Key? key, 
    required this.results,
    required this.prefs,
    required this.translator,
  }) : super(key: key);

  @override
  State<SearchResultsSelectionDialog> createState() => _SearchResultsSelectionDialogState();
}

class _SearchResultsSelectionDialogState extends State<SearchResultsSelectionDialog> {
  final Set<String> _selectedIds = {};
  bool _isSaving = false;
  String _loadingMessage = '';
  final RecipeService _recipeService = RecipeService();

  Future<Recipe> _translateSingleRecipe(Recipe original, String lang) async {
    // Combine text for single API call
    final sb = StringBuffer();
    sb.writeln(original.name);
    String flatInstructions = original.instructions.replaceAll('\n', ' ||| '); 
    sb.writeln(flatInstructions);
    for (var ing in original.ingredients) {
      sb.writeln(ing.name);
    }
    
    final translationResult = await widget.translator.translate(sb.toString(), to: lang);
    final List<String> lines = translationResult.text.split('\n');
    
    String translatedName = lines.isNotEmpty ? lines[0] : original.name;
    String translatedInstructionsRaw = lines.length > 1 ? lines[1] : original.instructions;
    String translatedInstructions = translatedInstructionsRaw.replaceAll(' ||| ', '\n');
    
    List<Ingredient> translatedIngredients = [];
    int ingredientStartIndex = 2;

    for (int i = 0; i < original.ingredients.length; i++) {
      String ingName;
      if (ingredientStartIndex + i < lines.length) {
        ingName = lines[ingredientStartIndex + i];
      } else {
        ingName = original.ingredients[i].name;
      }
      translatedIngredients.add(Ingredient(
        name: ingName,
        quantity: original.ingredients[i].quantity
      ));
    }
    
    return Recipe(
      id: original.id,
      name: translatedName,
      ingredients: translatedIngredients,
      instructions: translatedInstructions,
      imageUrl: original.imageUrl,
      category: original.category,
      area: original.area,
    );
  }

  void _saveSelected() async {
    if (_selectedIds.isEmpty) return;

    setState(() {
      _isSaving = true;
      _loadingMessage = 'Downloading recipes...';
    });

    try {
      int count = 0;
      final total = _selectedIds.length;

      for (String id in _selectedIds) {
        count++;
        setState(() => _loadingMessage = 'Processing $count / $total...');
        
        // 1. Fetch Original (English)
        final recipe = await _recipeService.fetchRecipeFromApi(id);
        
        if (recipe != null) {
          // 2. Save Original to DB
          await _recipeService.saveRecipeDirectly(recipe);

          // 3. Pre-Translate and Cache for supported languages (tr, de)
          if (widget.prefs != null) {
            // German
            setState(() => _loadingMessage = 'Translating to German ($count/$total)...');
            final deRecipe = await _translateSingleRecipe(recipe, 'de');
            await widget.prefs!.setString('recipe_trans_${recipe.id}_de', jsonEncode(deRecipe.toMap()));

            // Turkish
            setState(() => _loadingMessage = 'Translating to Turkish ($count/$total)...');
            final trRecipe = await _translateSingleRecipe(recipe, 'tr');
            await widget.prefs!.setString('recipe_trans_${recipe.id}_tr', jsonEncode(trRecipe.toMap()));
          }
        }
      }

      if (mounted) {
         Navigator.of(context).pop(); // Close dialog
         final l10n = AppLocalizations.of(context)!;
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recipesAddedSuccessfully)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.searchResults),
      content: SizedBox(
        width: double.maxFinite,
        child: _isSaving
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_loadingMessage, textAlign: TextAlign.center),
              ],
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final meal = widget.results[index];
                final isSelected = _selectedIds.contains(meal.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(meal.id);
                      } else {
                        _selectedIds.remove(meal.id);
                      }
                    });
                  },
                  secondary: meal.imageUrl != null 
                    ? CircleAvatar(backgroundImage: NetworkImage(meal.imageUrl!))
                    : const CircleAvatar(child: Icon(Icons.restaurant)),
                  title: Text(meal.name),
                );
              },
            ),
      ),
      actions: [
        if (!_isSaving) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _selectedIds.isNotEmpty ? _saveSelected : null,
            child: Text(l10n.addSelected),
          ),
        ]
      ],
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
