import 'package:flutter/material.dart';
// import 'package:remy/controllers/recipe_controller.dart'; // TODO: Descomentar
import 'package:remy/views/shared/widgets/recipe_card.dart';
import 'package:remy/views/shared/widgets/rating_widget.dart';

class StudentRecipeScreen extends StatefulWidget {
  final String studentId;
  final String classId;
  
  const StudentRecipeScreen({
    super.key,
    required this.studentId,
    required this.classId,
  });

  @override
  State<StudentRecipeScreen> createState() => _StudentRecipeScreenState();
}

class _StudentRecipeScreenState extends State<StudentRecipeScreen> {
  // TODO: Inicializar RecipeController
  // final RecipeController recipeController = RecipeController();
  
  int currentRecipeIndex = 0;
  bool isLoading = false;
  
  // Datos de ejemplo
  final List<Map<String, dynamic>> mockRecipes = [
    {
      'id': '1',
      'name': 'Mole Poblano',
      'category': 'Comida',
      'photo': null,
      'ingredients': '• 5 chiles mulato\n• 4 chiles ancho\n• 3 chiles pasilla\n• 1/2 taza de chocolate\n• 1/4 taza de pepitas\n• 1/4 taza de ajonjolí\n• 2 piezas de jitomate\n• 1 pieza de cebolla\n• 2 dientes de ajo\n• 1/4 taza de aceite\n• Sal al gusto',
      'procedure': '1. Limpia los chiles, retira las semillas y venas.\n2. Fríe los chiles en aceite caliente por 1-2 minutos.\n3. Remoja los chiles en agua caliente por 15 minutos.\n4. Muele los chiles con los demás ingredientes.\n5. Cocina la mezcla a fuego bajo por 30 minutos.\n6. Sirve sobre pollo o enchiladas.',
      'grade': 9.5,
    },
    {
      'id': '2',
      'name': 'Tamales Oaxaqueños',
      'category': 'Comida',
      'photo': null,
      'ingredients': '• 2 tazas de masa\n• 1/2 taza de manteca\n• 1 taza de caldo de pollo\n• 1 taza de mole\n• Hojas de maíz',
      'procedure': '1. Bate la manteca con la masa.\n2. Agrega el caldo de pollo gradualmente.\n3. Extiende la masa sobre las hojas de maíz.\n4. Agrega mole al centro.\n5. Dobla y cuece al vapor por 45 minutos.',
      'grade': 8.5,
    },
    {
      'id': '3',
      'name': 'Agua de Jamaica',
      'category': 'Bebida',
      'photo': null,
      'ingredients': '• 1 taza de flor de jamaica\n• 4 tazas de agua\n• 1/2 taza de azúcar\n• Hielo al gusto',
      'procedure': '1. Hierve el agua con la flor de jamaica.\n2. Deja reposar 10 minutos.\n3. Cuela y endulza al gusto.\n4. Sirve con hielo.',
      'grade': 7.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Cargar recetas desde Supabase
    // _loadRecipes();
  }

  /*
  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    try {
      final recipes = await recipeController.getStudentRecipes(
        widget.studentId,
        widget.classId,
      );
      setState(() {
        mockRecipes = recipes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar recetas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildNavigationButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Recetario del Alumno'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.grade),
          onPressed: _showGradeInfo,
          tooltip: 'Ver calificación',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // TODO: Recargar recetas
            // _loadRecipes();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recargando recetas...')),
            );
          },
          tooltip: 'Recargar',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mockRecipes.isEmpty) {
      return _buildEmptyState();
    }

    final recipe = mockRecipes[currentRecipeIndex];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(recipe);
        } else {
          return _buildMobileLayout(recipe);
        }
      },
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> recipe) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lista de recetas
          Expanded(
            flex: 1,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recetas (${mockRecipes.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: mockRecipes.length,
                        itemBuilder: (context, index) {
                          final r = mockRecipes[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: r['category'] == 'Comida'
                                  ? Colors.orange[100]
                                  : Colors.blue[100],
                              child: Icon(
                                r['category'] == 'Comida'
                                    ? Icons.restaurant
                                    : Icons.local_drink,
                                size: 20,
                                color: r['category'] == 'Comida'
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                            title: Text(
                              r['name'],
                              style: TextStyle(
                                fontWeight: currentRecipeIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(r['category']),
                            selected: currentRecipeIndex == index,
                            selectedTileColor: Colors.orange[50],
                            onTap: () {
                              setState(() {
                                currentRecipeIndex = index;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Detalle de la receta
          Expanded(
            flex: 2,
            child: _buildRecipeDetail(recipe),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> recipe) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildRecipeDetail(recipe),
    );
  }

  Widget _buildRecipeDetail(Map<String, dynamic> recipe) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto de la receta',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre y categoría
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recipe['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: recipe['category'] == 'Comida'
                        ? Colors.orange[100]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe['category'],
                    style: TextStyle(
                      color: recipe['category'] == 'Comida'
                          ? Colors.orange[700]
                          : Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Calificación
            if (recipe['grade'] != null)
              RatingWidget(
                rating: recipe['grade'],
                maxRating: 10,
              ),
            
            const SizedBox(height: 16),
            
            // Ingredientes
            _buildExpandableSection(
              icon: Icons.list,
              title: 'Ingredientes',
              content: recipe['ingredients'],
              initiallyExpanded: true,
            ),
            const SizedBox(height: 8),
            
            // Procedimiento
            _buildExpandableSection(
              icon: Icons.book,
              title: 'Procedimiento',
              content: recipe['procedure'],
              initiallyExpanded: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required IconData icon,
    required String title,
    required String content,
    bool initiallyExpanded = false,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: initiallyExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(height: 1.5),
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
          Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay recetas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este alumno aún no ha entregado recetas',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (mockRecipes.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: currentRecipeIndex > 0
              ? () {
                  setState(() {
                    currentRecipeIndex--;
                  });
                }
              : null,
          mini: true,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 16),
        Text(
          '${currentRecipeIndex + 1}/${mockRecipes.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: currentRecipeIndex < mockRecipes.length - 1
              ? () {
                  setState(() {
                    currentRecipeIndex++;
                  });
                }
              : null,
          mini: true,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  void _showGradeInfo() {
    // TODO: Mostrar información de calificación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calificación: 9.5/10'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}