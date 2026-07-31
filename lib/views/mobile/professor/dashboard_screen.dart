import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/auth_provider.dart';
import 'package:remy/providers/class_provider.dart';
import 'package:remy/views/mobile/professor/class_detail_screen.dart';
import 'package:remy/views/mobile/professor/create_class_screen.dart';
import 'package:remy/views/mobile/professor/profile_screen.dart';
import 'package:remy/views/shared/widgets/class_card.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';

class ProfessorDashboardScreen extends StatefulWidget {
  const ProfessorDashboardScreen({super.key});

  @override
  State<ProfessorDashboardScreen> createState() =>
      _ProfessorDashboardScreenState();
}

class _ProfessorDashboardScreenState extends State<ProfessorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await classProvider.loadClasses(authProvider.currentUser!.id);
    }
  }

  // ✅ Agrupar clases por cuatrimestre
  Map<String, List<dynamic>> _groupClassesByTerm() {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final Map<String, List<dynamic>> grouped = {};

    for (var classItem in classProvider.classes) {
      final term = classItem.term;
      if (!grouped.containsKey(term)) {
        grouped[term] = [];
      }
      grouped[term]!.add(classItem);
    }

    // Ordenar cuatrimestres
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      final aNum = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bNum = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return aNum.compareTo(bNum);
    });

    final sortedMap = <String, List<dynamic>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    return sortedMap;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);

    if (authProvider.isLoading || classProvider.isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando tus clases...'),
      );
    }

    final userName = authProvider.currentUser?.fullName ?? 'Profesor';
    final groupedClasses = _groupClassesByTerm();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mis Clases',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessorProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== SECCIÓN DE BIENVENIDA ==========
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFE65100),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Bienvenido, $userName!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        Text(
                          'Estas son tus clases',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ========== LISTA DE CLASES AGRUPADAS ==========
            if (classProvider.classes.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no tienes clases',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primera clase',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Crear Clase',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateClassScreen(),
                            ),
                          ).then((_) => _loadData());
                        },
                        width: 200,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: groupedClasses.entries.map((entry) {
                    return _buildTermSection(entry.key, entry.value);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateClassScreen(),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear Clase',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ========== CONSTRUIR SECCIÓN POR CUATRIMESTRE ==========
  Widget _buildTermSection(String term, List<dynamic> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del cuatrimestre
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.shade300,
              ),
            ),
            child: Text(
              term,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ),

        // Tarjetas de clases
        ...classes.map((classItem) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClassCard(
              classModel: classItem,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailScreen(
                      classId: classItem.id,
                      className: classItem.displayName,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),

        // Separador entre cuatrimestres
        const SizedBox(height: 8),
        Divider(
          color: Colors.grey.shade200,
          thickness: 1,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}