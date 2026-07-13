import 'package:flutter/material.dart';
// import 'package:remy/controllers/recipe_controller.dart'; // TODO: Descomentar
import 'package:remy/views/shared/responsive_layout.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class SearchRecipesScreen extends StatefulWidget {
  const SearchRecipesScreen({super.key});

  @override
  State<SearchRecipesScreen> createState() => _SearchRecipesScreenState();
}

class _SearchRecipesScreenState extends State<SearchRecipesScreen> {
  // TODO: Inicializar RecipeController
  // final RecipeController recipeController = RecipeController();

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? selectedType;
  String? selectedCountry;
  String? selectedCookingStyle;
  bool isLoading = false;
  bool showFilters = false;

  final List<String> typeOptions = ['Comida', 'Bebida'];
  final List<String> cookingStyleOptions = [
    'Horneado',
    'Frito',
    'Hervido',
    'Al vapor',
    'A la plancha',
    'Crudo',
    'Asado',
  ];

  // Datos de ejemplo -- recetas de otros alumnos, visibles para explorar/buscar
  final List<Map<String, dynamic>> mockRecipes = [
    {
      'id': 'r1',
      'name': 'Mole Poblano',
      'type': 'Comida',
      'country': 'México',
      'cooking_style': 'Hervido',
      'author': 'María González',
      'stars': 4,
    },
    {
      'id': 'r2',
      'name': 'Agua de Jamaica',
      'type': 'Bebida',
      'country': 'México',
      'cooking_style': 'Hervido',
      'author': 'Juan Pérez',
      'stars': 5,
    },
    {
      'id': 'r3',
      'name': 'Ceviche de Pescado',
      'type': 'Comida',
      'country': 'Perú',
      'cooking_style': 'Crudo',
      'author': 'Ana Martínez',
      'stars': 5,
    },
    {
      'id': 'r4',
      'name': 'Pan de Muerto',
      'type': 'Comida',
      'country': 'México',
      'cooking_style': 'Horneado',
      'author': 'Carlos López',
      'stars': 3,
    },
    {
      'id': 'r5',
      'name': 'Sangría',
      'type': 'Bebida',
      'country': 'España',
      'cooking_style': 'Crudo',
      'author': 'Laura Sánchez',
      'stars': null,
    },
  ];

  List<String> get countryOptions =>
      mockRecipes.map((r) => r['country'] as String).toSet().toList()..sort();

  List<Map<String, dynamic>> get _filteredRecipes {
    return mockRecipes.where((r) {
      final matchesQuery = searchQuery.isEmpty ||
          r['name'].toString().toLowerCase().contains(searchQuery);
      final matchesType = selectedType == null || r['type'] == selectedType;
      final matchesCountry =
          selectedCountry == null || r['country'] == selectedCountry;
      final matchesStyle = selectedCookingStyle == null ||
          r['cooking_style'] == selectedCookingStyle;
      return matchesQuery && matchesType && matchesCountry && matchesStyle;
    }).toList();
  }

  bool get _hasActiveFilters =>
      selectedType != null || selectedCountry != null || selectedCookingStyle != null;

  void _clearFilters() {
    setState(() {
      selectedType = null;
      selectedCountry = null;
      selectedCookingStyle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Recetas'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 900 ? 900.0 : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSearchBar(),
                  ),
                  if (showFilters)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildFiltersPanel(),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredRecipes.isEmpty
                            ? _buildEmptyState()
                            : ResponsiveLayout(
                                mobile: _buildGrid(1),
                                tablet: _buildGrid(2),
                                desktop: _buildGrid(3),
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: searchController,
            label: 'Buscar receta por nombre...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() => searchQuery = value.toLowerCase());
            },
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          children: [
            IconButton.filled(
              onPressed: () => setState(() => showFilters = !showFilters),
              icon: const Icon(Icons.tune),
              style: IconButton.styleFrom(
                backgroundColor: showFilters ? Colors.orange : Colors.grey[200],
                foregroundColor: showFilters ? Colors.white : Colors.grey[700],
              ),
            ),
            if (_hasActiveFilters)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersPanel() {
    return Card(
      elevation: 1,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: typeOptions
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedType = v),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: countryOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCountry = v),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: selectedCookingStyle,
                    decoration: const InputDecoration(
                      labelText: 'Estilo de cocción',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: cookingStyleOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCookingStyle = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredRecipes.length,
        itemBuilder: (context, index) => _buildResultCard(_filteredRecipes[index]),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> recipe) {
    final int? stars = recipe['stars'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRecipePreview(recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  recipe['type'] == 'Comida' ? Icons.restaurant : Icons.local_drink,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${recipe['country']} · ${recipe['cooking_style']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Por ${recipe['author']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    if (stars != null)
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < stars ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
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

  void _showRecipePreview(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${recipe['type']} · ${recipe['country']} · ${recipe['cooking_style']}'),
              const SizedBox(height: 4),
              Text('Autor: ${recipe['author']}', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              const Text(
                'TODO: Aquí se mostrará el detalle completo (ingredientes, procedimiento) '
                'consultando recipe_controller.getRecipeDetail(id).',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron recetas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término o quita algunos filtros',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}