import 'package:flutter/material.dart';
import 'package:remy/services/supabase_service.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';

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
  double? _currentGrade;
  bool _isGraded = false;
  String? _error;

  final SupabaseService _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  String _toSafeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    try {
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.assignmentId == null) {
        setState(() {
          _isLoading = false;
          _recipes = [];
        });
        return;
      }

      final response = await _supabase.supabase
          .from('recipes')
          .select('''
            *,
            image_url,
            grades!left (
              id,
              stars,
              graded_at
            )
          ''')
          .eq('assignment_id', widget.assignmentId as Object)
          .eq('student_id', widget.studentId)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> recipes = List<Map<String, dynamic>>.from(response);
      
      if (recipes.isNotEmpty) {
        final firstRecipe = recipes.first;
        if (firstRecipe['grades'] != null) {
          final grades = firstRecipe['grades'] as List;
          if (grades.isNotEmpty && grades.first['stars'] != null) {
            _isGraded = true;
            _currentGrade = (grades.first['stars'] as num).toDouble();
          }
        }
      }

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGrade(double rating) async {
    if (_recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay recetas para calificar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar calificación'),
        content: Text(
          '¿Estás seguro de calificar este recetario con $rating estrellas?\n\n⚠️ Una vez calificado, NO se podrá modificar.',
          style: TextStyle(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE65100),
            ),
            child: const Text('Calificar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final recipeId = _recipes.first['id'];

      final existingGrade = await _supabase.supabase
          .from('grades')
          .select()
          .eq('recipe_id', recipeId)
          .maybeSingle();

      if (!mounted) return;

      if (existingGrade != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Este recetario ya está calificado'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _supabase.supabase
          .from('grades')
          .insert({
            'recipe_id': recipeId,
            'stars': rating.round(),
            'graded_at': DateTime.now().toIso8601String(),
            'assignment_id': widget.assignmentId,
            'student_id': widget.studentId,
          });

      if (!mounted) return;

      setState(() {
        _currentGrade = rating;
        _isGraded = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Calificación de ${rating.toStringAsFixed(0)} estrellas guardada'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al calificar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🛠️ NUEVA FUNCIÓN PARA FORMATEAR EL JSON DE INGREDIENTES
  Widget _buildIngredients(dynamic ingredientsData) {
    if (ingredientsData == null) return const SizedBox.shrink();

    List<dynamic> ingredientsList = [];
    if (ingredientsData is List) {
      ingredientsList = ingredientsData;
    } else if (ingredientsData is String) {
      // Intentar parsear si es un string con formato JSON
      try {
        ingredientsList = List<dynamic>.from(ingredientsData as List);
      } catch (e) {
        // Si no se puede parsear, lo mostramos como texto simple
        return Text(
          ingredientsData,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        );
      }
    }

    if (ingredientsList.isEmpty) {
      return Text(
        'No especificados',
        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredientsList.map((item) {
        String name = '';
        String quantity = '';
        
        if (item is Map) {
          name = item['name']?.toString() ?? 'Ingrediente';
          quantity = item['quantity']?.toString() ?? '';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange)),
              Expanded(
                child: Text(
                  quantity.isNotEmpty ? '$name ($quantity)' : name,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando recetas...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar recetas',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRecipes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Recetario de ${widget.studentName}'),
          backgroundColor: const Color(0xFFE65100),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
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
        ),
      );
    }

    final recipe = _recipes[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Recetario de ${widget.studentName}'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isGraded && _currentGrade != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _currentGrade!.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ========== CALIFICACIÓN ==========
          if (!_isGraded)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    '⭐ Calificar recetario',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = (index + 1).toDouble();
                      return IconButton(
                        icon: Icon(
                          _currentGrade != null && _currentGrade! >= starValue
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () => _saveGrade(starValue),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca las estrellas para calificar (1-5)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Una vez calificado, NO se podrá modificar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // ✅ Ya calificado
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    '✅ Calificado: ${_currentGrade?.toStringAsFixed(0) ?? 0} estrellas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // ========== CONTENIDO CON SCROLL (CORREGIDO PARA WEB) ==========
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER DE RECETA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Receta ${_currentIndex + 1} de ${_recipes.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _toSafeString(recipe['name']),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // TIPO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _toSafeString(recipe['type']),
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🖼️ IMAGEN CORREGIDA PARA WEB
                  if (recipe['image_url'] != null && recipe['image_url'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 200,
                        maxHeight: 400, // Limita la altura máxima en pantallas grandes
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          recipe['image_url'].toString(),
                          // BoxFit.contain hace que la imagen se vea COMPLETA, sin cortarse ni estirarse
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Imagen no disponible', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // INGREDIENTES (Ahora con formato de lista)
                  const Text(
                    'Ingredientes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildIngredients(recipe['ingredients']),
                  const SizedBox(height: 16),

                  // PROCEDIMIENTO
                  const Text(
                    'Procedimiento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _toSafeString(recipe['procedure']),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 30), // Espacio extra al final
                ],
              ),
            ),
          ),

          // ========== NAVEGACIÓN INFERIOR ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 ? () {
                    setState(() => _currentIndex--);
                  } : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: _currentIndex > 0 ? const Color(0xFFE65100) : Colors.grey.shade300,
                ),
                Text(
                  '${_currentIndex + 1}/${_recipes.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  onPressed: _currentIndex < _recipes.length - 1 ? () {
                    setState(() => _currentIndex++);
                  } : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: _currentIndex < _recipes.length - 1 ? const Color(0xFFE65100) : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}