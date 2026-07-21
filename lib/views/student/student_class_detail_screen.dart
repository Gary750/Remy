import 'package:flutter/material.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/controllers/student_controller.dart';
import 'package:remy/models/assignment_model.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';

class StudentClassDetailScreen extends StatefulWidget {
  final String classId;

  const StudentClassDetailScreen({super.key, required this.classId});

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  final StudentController _studentController = StudentController();
  bool _isLoading = true;
  Map<String, dynamic>? _classData;
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final classData = await _studentController.getClassDetail(widget.classId);
      final assignments = await _studentController.getClassAssignments(widget.classId);

      if (mounted) {
        setState(() {
          _classData = classData;
          _assignments = assignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando detalles...'),
      );
    }

    if (_classData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Clase'),
          backgroundColor: const Color(0xFFE65100),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('No se encontró la clase')),
      );
    }

    final className = '${_classData!['subject']} - Grupo ${_classData!['group_name']}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          className,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información de la clase
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        _classData!['subject'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Profesor: ${_classData!['professor_id']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.event_note, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${_classData!['term']} Cuatrimestre - Grupo ${_classData!['group_name']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.vpn_key, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Código: ${_classData!['join_code']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Entregas
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Entregas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_assignments.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Text(
                  'No hay entregas disponibles',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ..._assignments.map((assignment) => _buildAssignmentCard(assignment)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final assignmentModel = AssignmentModel.fromJson(assignment);
    final isActive = assignmentModel.isActive;
    final hasSubmission = assignment['recipes'] != null && 
        (assignment['recipes'] as List).isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment['title'] ?? 'Entrega sin título',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Activa' : 'Cerrada',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Límite: ${_formatDate(assignment['due_date'])}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (assignment['instructions'] != null && assignment['instructions'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        assignment['instructions'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Botón de acción
            if (isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (hasSubmission) {
                      // Ver mi recetario entregado
                      Navigator.pushNamed(
                        context,
                        AppRoutes.studentMyRecipes,
                        arguments: {
                          'assignmentId': assignment['id'],
                          'classId': widget.classId,
                        },
                      );
                    } else {
                      // Subir recetario
                      Navigator.pushNamed(
                        context,
                        AppRoutes.studentUploadRecipe,
                        arguments: {
                          'assignmentId': assignment['id'],
                          'classId': widget.classId,
                          'recipeType': assignmentModel.recipeType,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasSubmission 
                        ? Colors.orange 
                        : const Color(0xFFE65100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    hasSubmission 
                        ? 'Ver mi recetario' 
                        : 'Subir recetario',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            else if (hasSubmission)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Entregado',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}