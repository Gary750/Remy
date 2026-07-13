import 'package:flutter/material.dart';
// import 'package:remy/controllers/class_controller.dart'; // TODO: Descomentar
// import 'package:remy/controllers/assignment_controller.dart'; // TODO: Descomentar
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';

class StudentClassDetailScreen extends StatefulWidget {
  final String classId;

  const StudentClassDetailScreen({super.key, required this.classId});

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  // TODO: Inicializar controllers
  // final ClassController classController = ClassController();
  // final AssignmentController assignmentController = AssignmentController();

  bool isLoading = false;

  // Datos de ejemplo -- reflejan las tablas classes / assignments / recipes / grades
  final Map<String, dynamic> mockClass = {
    'id': '1',
    'subject': 'Cocina Internacional',
    'term': '5°',
    'group_name': 'B',
    'join_code': 'GAS-5B-7K2',
  };

  final List<Map<String, dynamic>> mockAssignments = [
    {
      'id': 'a1',
      'title': 'Recetario Unidad 1 -- Entradas',
      'type': 'Comida',
      'due_date': DateTime.now().add(const Duration(hours: 6)),
      'delivered': true,
      'stars': 4,
    },
    {
      'id': 'a2',
      'title': 'Recetario Unidad 2 -- Bebidas típicas',
      'type': 'Bebida',
      'due_date': DateTime.now().add(const Duration(days: 3)),
      'delivered': false,
      'stars': null,
    },
    {
      'id': 'a3',
      'title': 'Proyecto final -- Platillo insignia',
      'type': 'Comida',
      'due_date': DateTime.now().add(const Duration(days: 10)),
      'delivered': false,
      'stars': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Cargar datos reales
    // _loadData();
  }

  /*
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final classData = await classController.getClassDetail(widget.classId);
      final assignments =
          await assignmentController.getAssignmentsForStudent(widget.classId);
      setState(() {
        mockClass = classData;
        mockAssignments = assignments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 900
                    ? 900.0
                    : constraints.maxWidth;
                return Center(
                  child: SizedBox(
                    width: maxWidth,
                    child: _buildBody(),
                  ),
                );
              },
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mockClass['subject'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${mockClass['term']} · Grupo ${mockClass['group_name']}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entregas (${mockAssignments.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca una entrega para subir o revisar tu receta',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: mockAssignments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: mockAssignments.length,
                    itemBuilder: (context, index) {
                      return _buildAssignmentCard(mockAssignments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final bool delivered = assignment['delivered'] == true;
    final DateTime dueDate = assignment['due_date'];
    final bool isOverdue = !delivered && dueDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleAssignmentTap(assignment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: assignment['type'] == 'Comida'
                    ? Colors.orange[100]
                    : Colors.blue[100],
                child: Icon(
                  assignment['type'] == 'Comida'
                      ? Icons.restaurant
                      : Icons.local_drink,
                  color: assignment['type'] == 'Comida'
                      ? Colors.orange
                      : Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverdue
                          ? 'Venció el ${_formatDate(dueDate)}'
                          : 'Fecha límite: ${_formatDate(dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(delivered, isOverdue, assignment['stars']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool delivered, bool isOverdue, int? stars) {
    if (delivered) {
      return Row(
        children: [
          if (stars != null) ...[
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(width: 6),
          ],
          const Chip(
            label: Text('Entregado', style: TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: Colors.green,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      );
    }

    return Chip(
      label: Text(
        isOverdue ? 'No entregado' : 'Pendiente',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: isOverdue ? Colors.red : Colors.orange,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no hay entregas publicadas',
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

  void _handleAssignmentTap(Map<String, dynamic> assignment) {
    if (assignment['delivered'] == true) {
      // Ya entregó -- navega a ver/editar su receta
      Navigator.pushNamed(
        context,
        AppRoutes.myRecipes,
        arguments: {
          'assignmentId': assignment['id'],
          'classId': widget.classId,
        },
      );
    } else {
      // Aún no entrega -- navega a subir receta
      Navigator.pushNamed(
        context,
        AppRoutes.uploadRecipe,
        arguments: {
          'assignmentId': assignment['id'],
          'classId': widget.classId,
          'recipeType': assignment['type'],
        },
      ).then((result) {
        if (result == true) {
          // TODO: Recargar assignments tras subir receta
          // _loadData();
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}