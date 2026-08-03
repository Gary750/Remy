import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remy/controllers/recipe_controller.dart';
import 'package:remy/views/shared/responsive_layout.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class SearchRecipesScreen extends StatefulWidget {
  const SearchRecipesScreen({super.key});

  @override
  State<SearchRecipesScreen> createState() => _SearchRecipesScreenState();
}

class _SearchRecipesScreenState extends State<SearchRecipesScreen> {
  final RecipeController recipeController = RecipeController();

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  String searchQuery = '';
  String? selectedType;
  String? selectedCountry;
  String? selectedCookingStyle;
  bool isLoading = false;
  bool showFilters = false;

  List<Map<String, dynamic>> results = [];
  List<String> countryOptions = [];

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

  bool get _hasActiveFilters =>
      selectedType != null || selectedCountry != null || selectedCookingStyle != null;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await recipeController.getAvailableCountries();
      if (mounted) setState(() => countryOptions = countries);
    } catch (_) {
      // silencio
    }
  }

  Future<void> _search() async {
    setState(() => isLoading = true);
    try {
      final data = await recipeController.searchRecipes(
        query: searchQuery,
        type: selectedType,
        country: selectedCountry,
        cookingStyle: selectedCookingStyle,
      );
      if (mounted) setState(() => results = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onQueryChanged(String value) {
    searchQuery = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  void _clearFilters() {
    setState(() {
      selectedType = null;
      selectedCountry = null;
      selectedCookingStyle = null;
    });
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Recetas'),
        backgroundColor: const Color(0xFFE65100),
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
                        : results.isEmpty
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
            onChanged: _onQueryChanged,
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          children: [
            IconButton.filled(
              onPressed: () => setState(() => showFilters = !showFilters),
              icon: const Icon(Icons.tune),
              style: IconButton.styleFrom(
                backgroundColor: showFilters ? const Color(0xFFE65100) : Colors.grey[200],
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
                    onChanged: (v) {
                      setState(() => selectedType = v);
                      _search();
                    },
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
                    onChanged: (v) {
                      setState(() => selectedCountry = v);
                      _search();
                    },
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
                    onChanged: (v) {
                      setState(() => selectedCookingStyle = v);
                      _search();
                    },
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
        itemCount: results.length,
        itemBuilder: (context, index) => _buildResultCard(results[index]),
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
                  image: recipe['image_url'] != null
                      ? DecorationImage(
                          image: NetworkImage(recipe['image_url']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: recipe['image_url'] == null
                    ? Icon(
                        recipe['type'] == 'Comida' ? Icons.restaurant : Icons.local_drink,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${recipe['country'] ?? ''} · ${recipe['cooking_style'] ?? ''}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Por ${recipe['author'] ?? 'Alumno'}',
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
    final List ingredients = recipe['ingredients'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  recipe['name'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${recipe['type']} · ${recipe['country']} · ${recipe['cooking_style'] ?? ''}'),
                const SizedBox(height: 4),
                Text('Autor: ${recipe['author'] ?? 'Alumno'}',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                const Text('Ingredientes', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• ${ing['name']} -- ${ing['quantity']}'),
                    )),
                const SizedBox(height: 16),
                const Text('Procedimiento', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(recipe['procedure'] ?? '', style: const TextStyle(height: 1.5)),
              ],
            );
          },
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