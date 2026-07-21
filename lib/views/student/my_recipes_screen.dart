import 'package:flutter/material.dart';
import 'package:remy/controllers/recipe_controller.dart';
import 'package:remy/views/shared/responsive_layout.dart';

class MyRecipesScreen extends StatefulWidget {
  final String? assignmentId;
  final String? classId;

  const MyRecipesScreen({
    super.key,
    this.assignmentId,
    this.classId,
  });

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final RecipeController recipeController = RecipeController();

  bool isLoading = true;
  String? selectedRecipeId;
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    try {
      final data = await recipeController.getMyRecipes();
      setState(() {
        recipes = data;
        if (widget.assignmentId != null) {
          final match = recipes.firstWhere(
            (r) => r['assignment_id'] == widget.assignmentId,
            orElse: () => {},
          );
          selectedRecipeId = match.isNotEmpty ? match['id'] : null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showingDetail = selectedRecipeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(showingDetail ? 'Mi Receta' : 'Mis Recetas'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (showingDetail && widget.assignmentId == null) {
              setState(() => selectedRecipeId = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? _buildEmptyState()
              : (showingDetail
                  ? _buildDetail(_findRecipe(selectedRecipeId!))
                  : _buildList()),
    );
  }

  Map<String, dynamic> _findRecipe(String id) {
    return recipes.firstWhere((r) => r['id'] == id);
  }

  Widget _buildList() {
    return ResponsiveLayout(
      mobile: _buildGrid(1),
      tablet: _buildGrid(2),
      desktop: _buildGrid(3),
    );
  }

  Widget _buildGrid(int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final int? stars = recipe['stars'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => selectedRecipeId = recipe['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  recipe['type'] == 'Comida'
                      ? Icons.restaurant
                      : Icons.local_drink,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe['country'] ?? ''} · ${recipe['type'] ?? ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    stars != null
                        ? _buildStars(stars)
                        : Text(
                            'Sin calificar',
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(int stars) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }

  Widget _buildDetail(Map<String, dynamic> recipe) {
    final int? stars = recipe['stars'];
    final List ingredients = recipe['ingredients'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: maxWidth,
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: recipe['image_url'] != null
                              ? DecorationImage(
                                  image: NetworkImage(recipe['image_url']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: recipe['image_url'] == null
                            ? Icon(Icons.image, size: 56, color: Colors.grey[400])
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipe['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: recipe['type'] == 'Comida'
                                  ? Colors.orange[100]
                                  : Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recipe['type'] ?? '',
                              style: TextStyle(
                                color: recipe['type'] == 'Comida'
                                    ? Colors.orange[700]
                                    : Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recipe['country'] ?? ''}${recipe['region'] != null && recipe['region'].toString().isNotEmpty ? ' · ${recipe['region']}' : ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      if (stars != null)
                        _buildStars(stars)
                      else
                        Chip(
                          label: const Text('Pendiente de calificación'),
                          backgroundColor: Colors.orange[50],
                          labelStyle: TextStyle(color: Colors.orange[700]),
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (recipe['prep_time'] != null && recipe['prep_time'].toString().isNotEmpty)
                            _buildInfoChip(Icons.timer, recipe['prep_time']),
                          if (recipe['portions'] != null && recipe['portions'].toString().isNotEmpty)
                            _buildInfoChip(Icons.people, '${recipe['portions']} porciones'),
                          if (recipe['cooking_style'] != null)
                            _buildInfoChip(Icons.local_fire_department, recipe['cooking_style']),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (recipe['mise_en_place'] != null &&
                          recipe['mise_en_place'].toString().isNotEmpty)
                        _buildExpandable('Mise en place', recipe['mise_en_place']),
                      _buildIngredientsList(ingredients),
                      _buildExpandable('Procedimiento', recipe['procedure'] ?? '',
                          initiallyExpanded: true),
                      if (recipe['sauce'] != null && recipe['sauce'].toString().isNotEmpty)
                        _buildExpandable('Salsa / acompañamiento', recipe['sauce']),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildIngredientsList(List ingredients) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Icon(Icons.list, color: Colors.orange),
        title: const Text('Ingredientes', style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: ingredients.map<Widget>((ing) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.circle, size: 8),
            title: Text(ing['name'] ?? ''),
            trailing: Text(ing['quantity'] ?? '', style: TextStyle(color: Colors.grey[600])),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandable(String title, String content, {bool initiallyExpanded = false}) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Icon(Icons.description, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: initiallyExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(content, style: const TextStyle(height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no has subido recetas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}