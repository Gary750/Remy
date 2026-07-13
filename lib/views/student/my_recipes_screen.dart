import 'package:flutter/material.dart';
// import 'package:remy/controllers/recipe_controller.dart'; // TODO: Descomentar
import 'package:remy/views/shared/responsive_layout.dart';

class MyRecipesScreen extends StatefulWidget {
  /// Si se provee, la pantalla abre directo el detalle de esa receta.
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
  // TODO: Inicializar RecipeController
  // final RecipeController recipeController = RecipeController();

  bool isLoading = false;
  String? selectedRecipeId;

  // Datos de ejemplo -- reflejan la tabla recipes + grades
  final List<Map<String, dynamic>> mockRecipes = [
    {
      'id': 'r1',
      'assignment_id': 'a1',
      'name': 'Mole Poblano',
      'type': 'Comida',
      'country': 'México',
      'region': 'Puebla',
      'cooking_style': 'Hervido',
      'image_url': null,
      'mise_en_place': 'Limpiar y desvenar los chiles. Tostar las especias.',
      'ingredients': [
        {'name': 'Chile mulato', 'quantity': '5 piezas'},
        {'name': 'Chile ancho', 'quantity': '4 piezas'},
        {'name': 'Chocolate de mesa', 'quantity': '1/2 taza'},
        {'name': 'Pepitas', 'quantity': '1/4 taza'},
      ],
      'sauce': null,
      'procedure':
          '1. Limpia los chiles.\n2. Fríe brevemente.\n3. Remoja 15 min.\n4. Muele con el resto de ingredientes.\n5. Cocina 30 min a fuego bajo.',
      'prep_time': '90 min',
      'portions': '6',
      'stars': 4,
    },
    {
      'id': 'r2',
      'assignment_id': 'a4',
      'name': 'Agua de Jamaica',
      'type': 'Bebida',
      'country': 'México',
      'region': 'Nacional',
      'cooking_style': 'Hervido',
      'image_url': null,
      'mise_en_place': 'Lavar la flor de jamaica.',
      'ingredients': [
        {'name': 'Flor de jamaica', 'quantity': '1 taza'},
        {'name': 'Agua', 'quantity': '4 tazas'},
        {'name': 'Azúcar', 'quantity': '1/2 taza'},
      ],
      'sauce': null,
      'procedure':
          '1. Hierve el agua con la jamaica.\n2. Reposa 10 min.\n3. Cuela y endulza.',
      'prep_time': '20 min',
      'portions': '4',
      'stars': null, // Aún sin calificar
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedRecipeId = widget.assignmentId != null
        ? mockRecipes.firstWhere(
            (r) => r['assignment_id'] == widget.assignmentId,
            orElse: () => mockRecipes.isNotEmpty ? mockRecipes.first : {},
          )['id']
        : null;
    // TODO: Cargar recetas reales del alumno
    // _loadRecipes();
  }

  /*
  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    try {
      final recipes = await recipeController.getMyRecipes();
      setState(() => mockRecipes = recipes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recetas: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    final bool showingDetail = selectedRecipeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(showingDetail ? 'Mi Receta' : 'Mis Recetas'),
        backgroundColor: Colors.orange,
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
          : mockRecipes.isEmpty
              ? _buildEmptyState()
              : (showingDetail
                  ? _buildDetail(_findRecipe(selectedRecipeId!))
                  : _buildList()),
    );
  }

  Map<String, dynamic> _findRecipe(String id) {
    return mockRecipes.firstWhere((r) => r['id'] == id);
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
        itemCount: mockRecipes.length,
        itemBuilder: (context, index) {
          final recipe = mockRecipes[index];
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
                      recipe['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe['country']} · ${recipe['type']}',
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
                        ),
                        child: Icon(Icons.image, size: 56, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipe['name'],
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
                              recipe['type'],
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
                        '${recipe['country']}${recipe['region'] != null ? ' · ${recipe['region']}' : ''}',
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
                          if (recipe['prep_time'] != null)
                            _buildInfoChip(Icons.timer, recipe['prep_time']),
                          if (recipe['portions'] != null)
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
        leading: const Icon(Icons.list, color: Colors.orange),
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
        leading: const Icon(Icons.description, color: Colors.orange),
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