import 'package:flutter/material.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/responsive_layout.dart';
import 'package:remy/views/shared/widgets/class_card.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'join_class_screen.dart'; // Importamos el modal que creamos arriba

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  // Datos simulados (luego los traeremos de Supabase)
  final List<Map<String, dynamic>> mockClasses = [
    {
      'id': '1',
      'className': 'Cocina Internacional',
      'time_left': 'Faltan 6 horas',
    },
    {
      'id': '2',
      'className': 'Repostería Básica',
      'time_left': 'Faltan 3 días',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navegación al perfil del alumno
              // Navigator.pushNamed(context, AppRoutes.profile);
            },
            tooltip: 'Mi Perfil',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildContent(crossAxisCount: 1),
        tablet: _buildContent(crossAxisCount: 2),
        desktop: _buildContent(crossAxisCount: 3),
      ),
    );
  }

  Widget _buildContent({required int crossAxisCount}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Clases en las que estás inscrito',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              CustomButton(
                text: 'Unirse a clase',
                onPressed: () => showJoinClassModal(context),
                width: 150,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: mockClasses.isEmpty
                ? _buildEmptyState()
                : _buildGrid(crossAxisCount),
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
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes clases',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey[600]
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pídele el código a tu profesor y únete.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(int crossAxisCount) {
    // Usamos un GridView para aprovechar el ResponsiveLayout. 
    // En móvil (crossAxisCount = 1) se verá como una lista normal.
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: mockClasses.length + 1, // +1 para el botón de "Unirse a otra"
      itemBuilder: (context, index) {
        if (index == mockClasses.length) {
          return _buildJoinAnotherClassCard();
        }

        final cls = mockClasses[index];
        return ClassCard(
          className: cls['className'],
          // Pasamos 0 porque a tu ClassCard le pusiste estas variables como required, 
          // pero como encendemos isStudent: true, no se van a dibujar en pantalla.
          studentsCount: 0, 
          deliveredCount: 0,
          isStudent: true,
          onTap: () => Navigator.pushNamed(context, AppRoutes.studentClassDetail, arguments: cls['id']),
          /*onTap: () {
            // Navegación al detalle de la clase para ver entregas
            // Navigator.pushNamed(context, AppRoutes.studentClassDetail, arguments: cls['id']);
            
          },*/
        );
      },
    );
  }

  Widget _buildJoinAnotherClassCard() {
    return Card(
      elevation: 0,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange[200]!, style: BorderStyle.solid),
      ),
      child: InkWell(
        onTap: () => showJoinClassModal(context),
        borderRadius: BorderRadius.circular(12),
        child: const Center(
          child: Text(
            'Unirse a otra clase',
            style: TextStyle(
              color: Colors.orange, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}