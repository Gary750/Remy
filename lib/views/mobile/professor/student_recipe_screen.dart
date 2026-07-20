import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/enrollment_provider.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';
import 'package:remy/views/shared/widgets/recipe_card.dart';

class StudentRecipeScreen extends StatefulWidget {
  final String classId;
  final String studentId;
  final String studentName;
  final String? assignmentId;

  const StudentRecipeScreen({
    super.key,
    required this.classId,
    required this.studentId,
    required this.studentName,
    this.assignmentId,
  });

  @override
  State<StudentRecipeScreen> createState() => _StudentRecipeScreenState();
}

class _StudentRecipeScreenState extends State<StudentRecipeScreen> {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (widget.assignmentId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // TODO: Implementar carga de recetas desde Supabase
    // Por ahora datos de ejemplo
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _recipes = [
        {
          'name': 'Enchiladas Verdes',
          'type': 'Comida',
          'ingredients': 'Tortillas, pollo, salsa verde, crema',
          'procedure': '1. Cocinar pollo\n2. Preparar salsa\n3. Armar enchiladas',
          'image_url': null,
        },
        {
          'name': 'Agua de Jamaica',
          'type': 'Bebida',
          'ingredients': 'Jamaica, agua, azúcar',
          'procedure': '1. Hervir jamaica\n2. Endulzar\n3. Enfriar',
          'image_url': null,
        },
      ];
      _isLoading = false;
    });
  }

  void _nextRecipe() {
    if (_currentIndex < _recipes.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previousRecipe() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recetario de ${widget.studentName}'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando recetas...')
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay recetas entregadas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Contador
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Receta ${_currentIndex + 1} de ${_recipes.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // Receta
                    Expanded(
                      child: RecipeCard(
                        recipe: _recipes[_currentIndex],
                      ),
                    ),

                    // Navegación
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _currentIndex > 0 ? _previousRecipe : null,
                            icon: const Icon(Icons.arrow_back_ios),
                            color: _currentIndex > 0
                                ? const Color(0xFFE65100)
                                : Colors.grey.shade300,
                          ),
                          Text(
                            '${_currentIndex + 1}/${_recipes.length}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _currentIndex < _recipes.length - 1
                                    ? _nextRecipe
                                    : null,
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: _currentIndex < _recipes.length - 1
                                ? const Color(0xFFE65100)
                                : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}