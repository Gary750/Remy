import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/auth_provider.dart';
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

      // ✅ Obtener recetas del alumno (simulado, sin Supabase)
      // TODO: Conectar con Supabase
      await Future.delayed(const Duration(milliseconds: 500));
      
      final List<Map<String, dynamic>> recipes = [
        {
          'id': '1',
          'name': 'Enchiladas Verdes',
          'type': 'Comida',
          'ingredients': 'Tortillas, pollo, salsa verde, crema',
          'procedure': '1. Cocinar pollo\n2. Preparar salsa\n3. Armar enchiladas',
          'image_url': null,
        },
        {
          'id': '2',
          'name': 'Agua de Jamaica',
          'type': 'Bebida',
          'ingredients': 'Jamaica, agua, azúcar',
          'procedure': '1. Hervir jamaica\n2. Endulzar\n3. Enfriar',
          'image_url': null,
        },
      ];

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
          // ✅ Mostrar calificación en el AppBar
          if (_isGraded && _currentGrade != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _currentGrade!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ========== CALIFICACIÓN CON ESTRELLAS ==========
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
                    'Calificar recetario',
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
                        onPressed: () {
                          setState(() {
                            _currentGrade = starValue;
                            _isGraded = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Calificación de ${starValue.toStringAsFixed(0)} estrellas'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca las estrellas para calificar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            // ✅ Si ya está calificado, mostrar solo la calificación
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
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Calificado: ${_currentGrade?.toStringAsFixed(0) ?? 0} estrellas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // ========== CONTADOR ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
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
                  recipe['name'] ?? 'Receta sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== TIPO ==========
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe['type'] ?? 'Comida',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ========== INGREDIENTES ==========
                    const Text(
                      'Ingredientes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['ingredients'] ?? 'No especificados',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ========== PROCEDIMIENTO ==========
                    const Text(
                      'Procedimiento',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['procedure'] ?? 'No especificado',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ========== NAVEGACIÓN ==========
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