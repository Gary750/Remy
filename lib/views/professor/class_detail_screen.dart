import 'package:flutter/material.dart';
// import 'package:remy/controllers/class_controller.dart'; // TODO: Descomentar
// import 'package:remy/controllers/assignment_controller.dart'; // TODO: Descomentar
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/student_tile.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  
  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  // TODO: Inicializar controllers
  // final ClassController classController = ClassController();
  // final AssignmentController assignmentController = AssignmentController();
  
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? selectedFilter;
  bool isLoading = false;
  
  // Datos de ejemplo
  final Map<String, dynamic> mockClass = {
    'id': '1',
    'name': 'Cocina Mexicana I -- Grupo B',
    'code': 'GAS-5B-7K2',
    'semester': '5°',
    'subject': 'Cocina Mexicana I',
    'group': 'B',
  };
  
  final List<Map<String, dynamic>> mockStudents = [
    {'id': '1', 'name': 'María González', 'status': 'Entregado', 'grade': 9.5},
    {'id': '2', 'name': 'Juan Pérez', 'status': 'Pendiente', 'grade': null},
    {'id': '3', 'name': 'Ana Martínez', 'status': 'Entregado', 'grade': 8.0},
    {'id': '4', 'name': 'Carlos López', 'status': 'No entregado', 'grade': null},
    {'id': '5', 'name': 'Laura Sánchez', 'status': 'Entregado', 'grade': 10.0},
  ];

  final List<String> filterOptions = ['Todos', 'Entregado', 'Pendiente', 'No entregado'];

  @override
  void initState() {
    super.initState();
    // TODO: Cargar datos desde Supabase
    // _loadClassData();
  }

  /*
  Future<void> _loadClassData() async {
    setState(() => isLoading = true);
    try {
      final classData = await classController.getClassDetail(widget.classId);
      final students = await classController.getStudents(widget.classId);
      setState(() {
        mockClass = classData;
        mockStudents = students;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.createAssignment,
          arguments: widget.classId,
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
        tooltip: 'Nueva Entrega',
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mockClass['name'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Código: ${mockClass['code']}',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareClassCode,
          tooltip: 'Compartir código',
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alumnos inscritos (${mockStudents.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomButton(
                text: 'Nueva Entrega',
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.createAssignment,
                  arguments: widget.classId,
                ),
                icon: Icons.add,
                width: 200,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchAndFilters(),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: Card(
                elevation: 2,
                child: Column(
                  children: [
                    _buildTableHeader(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return StudentTile(
                            name: student['name'],
                            status: student['status'],
                            grade: student['grade'],
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.studentRecipe,
                              arguments: {
                                'studentId': student['id'],
                                'classId': widget.classId,
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildSearchAndFilters(),
              const SizedBox(height: 12),
              Text(
                'Alumnos (${mockStudents.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return StudentTile(
                  name: student['name'],
                  status: student['status'],
                  grade: student['grade'],
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.studentRecipe,
                    arguments: {
                      'studentId': student['id'],
                      'classId': widget.classId,
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            controller: searchController,
            label: 'Buscar por nombre...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            hint: const Text('Filtrar'),
            items: filterOptions.map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text('Alumno', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Expanded(
            flex: 2,
            child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Expanded(
            flex: 1,
            child: Text('Calif.', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return mockStudents.where((student) {
      final matchesSearch = student['name'].toLowerCase().contains(searchQuery);
      final matchesFilter = selectedFilter == null || 
          selectedFilter == 'Todos' ||
          student['status'] == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _shareClassCode() {
    // TODO: Implementar compartir código
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado: ${mockClass['code']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}