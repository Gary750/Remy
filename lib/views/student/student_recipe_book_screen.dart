import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remy/controllers/recipe_controller.dart';
import 'package:remy/views/shared/responsive_layout.dart';

class StudentRecipeBookScreen extends StatefulWidget {
  const StudentRecipeBookScreen({super.key});

  @override
  State<StudentRecipeBookScreen> createState() =>
      _StudentRecipeBookScreenState();
}

class _StudentRecipeBookScreenState extends State<StudentRecipeBookScreen> {
  final RecipeController _recipeController = RecipeController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];

  // Filtros
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedCountry;
  String? _selectedCookingStyle;
  bool _showFilters = false;

  // Opciones de filtros
  List<String> _countryOptions = [];
  List<String> _cookingStyleOptions = [];
  final List<String> _typeOptions = ['Comida', 'Bebida'];

  // Detalle
  String? _selectedRecipeId;

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedCountry != null ||
      _selectedCookingStyle != null;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final data = await _recipeController.getMyRecipes();
      if (mounted) {
        setState(() {
          _allRecipes = data;
          _extractFilterOptions();
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _extractFilterOptions() {
    final countries = _allRecipes
        .map((r) => r['country'] as String?)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    countries.sort();

    final styles = _allRecipes
        .map((r) => r['cooking_style'] as String?)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    styles.sort();

    _countryOptions = countries;
    _cookingStyleOptions = styles;
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allRecipes);

    // Filtro por nombre
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final name = (r['name'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtro por tipo
    if (_selectedType != null) {
      filtered = filtered.where((r) => r['type'] == _selectedType).toList();
    }

    // Filtro por país
    if (_selectedCountry != null) {
      filtered =
          filtered.where((r) => r['country'] == _selectedCountry).toList();
    }

    // Filtro por estilo de cocción
    if (_selectedCookingStyle != null) {
      filtered = filtered
          .where((r) => r['cooking_style'] == _selectedCookingStyle)
          .toList();
    }

    setState(() => _filteredRecipes = filtered);
  }

  void _onQueryChanged(String value) {
    _searchQuery = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applyFilters);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCountry = null;
      _selectedCookingStyle = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRecipeId != null) {
      final recipe = _allRecipes.firstWhere(
        (r) => r['id'] == _selectedRecipeId,
        orElse: () => {},
      );
      if (recipe.isNotEmpty) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            setState(() => _selectedRecipeId = null);
          },
          child: _buildDetailView(recipe),
        );
      }
    }

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildSearchBar(),
        ),

        // Filtros
        if (_showFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildFiltersPanel(),
          ),

        // Contador de resultados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.menu_book, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                '${_filteredRecipes.length} receta${_filteredRecipes.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Lista de recetas
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRecipes.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadRecipes,
                      child: ResponsiveLayout(
                        mobile: _buildRecipeList(1),
                        tablet: _buildRecipeList(2),
                        desktop: _buildRecipeList(3),
                      ),
                    ),
        ),
      ],
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Buscar receta por nombre...',
              prefixIcon:
                  Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _applyFilters();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          children: [
            Material(
              color: _showFilters
                  ? const Color(0xFFE65100)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _showFilters = !_showFilters),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.tune,
                    color: _showFilters ? Colors.white : Colors.grey.shade700,
                  ),
                ),
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

  // ==================== FILTERS ====================
  Widget _buildFiltersPanel() {
    return Card(
      elevation: 1,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filtros',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar',
                        style: TextStyle(color: Color(0xFFE65100))),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFilterDropdown(
                  label: 'Tipo',
                  value: _selectedType,
                  items: _typeOptions,
                  onChanged: (v) {
                    setState(() => _selectedType = v);
                    _applyFilters();
                  },
                ),
                if (_countryOptions.isNotEmpty)
                  _buildFilterDropdown(
                    label: 'País',
                    value: _selectedCountry,
                    items: _countryOptions,
                    onChanged: (v) {
                      setState(() => _selectedCountry = v);
                      _applyFilters();
                    },
                  ),
                if (_cookingStyleOptions.isNotEmpty)
                  _buildFilterDropdown(
                    label: 'Estilo de cocción',
                    value: _selectedCookingStyle,
                    items: _cookingStyleOptions,
                    onChanged: (v) {
                      setState(() => _selectedCookingStyle = v);
                      _applyFilters();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ==================== RECIPE LIST ====================
  Widget _buildRecipeList(int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: crossAxisCount == 1 ? 3.0 : 1.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredRecipes.length,
        itemBuilder: (context, index) =>
            _buildRecipeCard(_filteredRecipes[index]),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final int? stars = recipe['stars'];
    final String? imageUrl = recipe['image_url'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => _selectedRecipeId = recipe['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen / ícono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Icon(
                        recipe['type'] == 'Comida'
                            ? Icons.restaurant
                            : Icons.local_drink,
                        color: Colors.grey.shade400,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      [
                        recipe['country'],
                        recipe['type'],
                        recipe['cooking_style'],
                      ].where((s) => s != null && s.toString().isNotEmpty).join(' · '),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    stars != null
                        ? Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < stars ? Icons.star : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              );
                            }),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Sin calificar',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              // Flecha
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DETAIL VIEW ====================
  Widget _buildDetailView(Map<String, dynamic> recipe) {
    final int? stars = recipe['stars'];
    final List ingredients = recipe['ingredients'] ?? [];

    return Column(
      children: [
        // Barra superior del detalle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedRecipeId = null),
              ),
              const Expanded(
                child: Text(
                  'Detalle de Receta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Contenido
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: recipe['image_url'] != null
                            ? DecorationImage(
                                image: NetworkImage(recipe['image_url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: recipe['image_url'] == null
                          ? Icon(Icons.image,
                              size: 56, color: Colors.grey.shade400)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Nombre y tipo
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: recipe['type'] == 'Comida'
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe['type'] ?? '',
                            style: TextStyle(
                              color: recipe['type'] == 'Comida'
                                  ? Colors.orange.shade700
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // País y región
                    Text(
                      '${recipe['country'] ?? ''}${recipe['region'] != null && recipe['region'].toString().isNotEmpty ? ' · ${recipe['region']}' : ''}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    // Calificación
                    if (stars != null)
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < stars ? Icons.star : Icons.star_border,
                            size: 20,
                            color: Colors.amber,
                          );
                        }),
                      )
                    else
                      Chip(
                        label: const Text('Pendiente de calificación'),
                        backgroundColor: Colors.orange.shade50,
                        labelStyle:
                            TextStyle(color: Colors.orange.shade700),
                      ),
                    const SizedBox(height: 16),

                    // Info chips
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (recipe['prep_time'] != null &&
                            recipe['prep_time'].toString().isNotEmpty)
                          _buildInfoChip(Icons.timer, recipe['prep_time']),
                        if (recipe['portions'] != null &&
                            recipe['portions'].toString().isNotEmpty)
                          _buildInfoChip(Icons.people,
                              '${recipe['portions']} porciones'),
                        if (recipe['cooking_style'] != null)
                          _buildInfoChip(Icons.local_fire_department,
                              recipe['cooking_style']),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mise en place
                    if (recipe['mise_en_place'] != null &&
                        recipe['mise_en_place'].toString().isNotEmpty)
                      _buildExpandable(
                          'Mise en place', recipe['mise_en_place']),

                    // Ingredientes
                    _buildIngredientsList(ingredients),

                    // Procedimiento
                    _buildExpandable(
                        'Procedimiento', recipe['procedure'] ?? '',
                        initiallyExpanded: true),

                    // Salsa
                    if (recipe['sauce'] != null &&
                        recipe['sauce'].toString().isNotEmpty)
                      _buildExpandable(
                          'Salsa / acompañamiento', recipe['sauce']),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildIngredientsList(List ingredients) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.list, color: Colors.orange),
        title: const Text('Ingredientes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: ingredients.map<Widget>((ing) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.circle, size: 8),
            title: Text(ing['name'] ?? ''),
            trailing: Text(ing['quantity'] ?? '',
                style: TextStyle(color: Colors.grey.shade600)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandable(String title, String content,
      {bool initiallyExpanded = false}) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.description, color: Colors.orange),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    final bool hasFilters =
        _searchQuery.isNotEmpty || _hasActiveFilters;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.menu_book_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'No se encontraron recetas'
                : 'Aún no tienes recetas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Intenta con otro término o quita algunos filtros'
                : 'Sube recetas en tus entregas de clase',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
