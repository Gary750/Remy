import 'package:flutter/material.dart';
// import 'package:remy/controllers/student_controller.dart'; // TODO: Descomentar

class MyGradesScreen extends StatefulWidget {
  const MyGradesScreen({super.key});

  @override
  State<MyGradesScreen> createState() => _MyGradesScreenState();
}

class _MyGradesScreenState extends State<MyGradesScreen> {
  // TODO: Inicializar StudentController
  // final StudentController studentController = StudentController();

  bool isLoading = false;

  // Datos de ejemplo -- reflejan classes + assignments + recipes + grades
  final List<Map<String, dynamic>> mockGradesByClass = [
    {
      'class_id': '1',
      'subject': 'Cocina Internacional',
      'group_name': 'B',
      'grades': [
        {'assignment_title': 'Recetario Unidad 1 -- Entradas', 'recipe_name': 'Mole Poblano', 'stars': 4},
        {'assignment_title': 'Recetario Unidad 2 -- Bebidas típicas', 'recipe_name': null, 'stars': null},
      ],
    },
    {
      'class_id': '2',
      'subject': 'Repostería Básica',
      'group_name': 'A',
      'grades': [
        {'assignment_title': 'Proyecto final -- Pastel', 'recipe_name': 'Pastel Tres Leches', 'stars': 5},
        {'assignment_title': 'Práctica -- Pan dulce', 'recipe_name': 'Concha', 'stars': 3},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Cargar calificaciones reales
    // _loadGrades();
  }

  /*
  Future<void> _loadGrades() async {
    setState(() => isLoading = true);
    try {
      final grades = await studentController.getMyGrades();
      setState(() => mockGradesByClass = grades);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar calificaciones: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  */

  double? get _overallAverage {
    final allStars = mockGradesByClass
        .expand((c) => c['grades'] as List)
        .map((g) => g['stars'])
        .where((s) => s != null)
        .cast<int>()
        .toList();
    if (allStars.isEmpty) return null;
    return allStars.reduce((a, b) => a + b) / allStars.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mockGradesByClass.isEmpty
              ? _buildEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth =
                        constraints.maxWidth > 800 ? 800.0 : constraints.maxWidth;
                    return Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildAverageCard(),
                            const SizedBox(height: 20),
                            ...mockGradesByClass.map(_buildClassSection),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildAverageCard() {
    final avg = _overallAverage;
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promedio general',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  avg != null
                      ? Row(
                          children: [
                            Text(
                              avg.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text(' / 5', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : const Text('Aún sin calificaciones'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSection(Map<String, dynamic> classData) {
    final List grades = classData['grades'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${classData['subject']} · Grupo ${classData['group_name']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: grades.map<Widget>((g) => _buildGradeRow(g)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeRow(Map<String, dynamic> grade) {
    final int? stars = grade['stars'];

    return ListTile(
      title: Text(grade['assignment_title']),
      subtitle: Text(
        grade['recipe_name'] != null
            ? 'Receta: ${grade['recipe_name']}'
            : 'Aún no entregado',
        style: TextStyle(
          fontSize: 12,
          color: grade['recipe_name'] != null ? Colors.grey[600] : Colors.orange,
        ),
      ),
      trailing: stars != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 18,
                  color: Colors.amber,
                );
              }),
            )
          : Text(
              'Pendiente',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes calificaciones',
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