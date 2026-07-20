import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/assignment_provider.dart';
import 'package:remy/providers/enrollment_provider.dart';
import 'package:remy/views/mobile/professor/create_assignment_screen.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';
import 'package:remy/views/shared/widgets/student_tile.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.wait([
      Provider.of<EnrollmentProvider>(context, listen: false)
          .loadStudents(widget.classId),
      Provider.of<AssignmentProvider>(context, listen: false)
          .loadAssignments(widget.classId),
    ]);
  }

  List<Map<String, dynamic>> get _filteredStudents {
    final students = Provider.of<EnrollmentProvider>(context).students;

    if (_searchQuery.isEmpty) return students;

    return students.where((student) {
      final name = student['profiles']['full_name']?.toLowerCase() ?? '';
      final email = student['profiles']['email']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
    final assignmentProvider = Provider.of<AssignmentProvider>(context);

    if (enrollmentProvider.isLoading || assignmentProvider.isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando detalles...'),
      );
    }

    final activeAssignment = assignmentProvider.activeAssignment;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${enrollmentProvider.students.length} alumnos',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (activeAssignment != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.task_alt, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrega activa: ${activeAssignment.title}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Vence en: ${activeAssignment.timeRemaining}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _filteredStudents.isEmpty
                ? Center(
                    child: Text(
                      'No hay alumnos que coincidan',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      final profile = student['profiles'] as Map<String, dynamic>;

                      return StudentTile(
                        name: profile['full_name'] ?? 'Sin nombre',
                        email: profile['email'] ?? '',
                        status: index % 2 == 0 ? 'Entregado' : 'Pendiente',
                        grade: index % 2 == 0 ? 8.5 + (index * 0.2) : null,
                        avatarUrl: profile['avatar_url'],
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAssignmentScreen(
                classId: widget.classId,
              ),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Entrega',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}