import 'package:flutter/material.dart';
import 'package:remy/controllers/student_controller.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/responsive_layout.dart';
import 'package:remy/views/shared/widgets/class_card.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'join_class_screen.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  final StudentController studentController = StudentController();

  bool isLoading = true;
  List<Map<String, dynamic>> classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => isLoading = true);
    try {
      final data = await studentController.getMyClasses();
      if (mounted) setState(() => classes = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            tooltip: 'Mi Perfil',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
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
                onPressed: () => showJoinClassModal(context, onJoined: _loadClasses),
                width: 150,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: classes.isEmpty
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
              color: Colors.grey[600],
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: classes.length + 1, // +1 para el botón de "Unirse a otra"
      itemBuilder: (context, index) {
        if (index == classes.length) {
          return _buildJoinAnotherClassCard();
        }

        final cls = classes[index];
        return ClassCard(
          className: '${cls['subject']} · Grupo ${cls['group_name']}',
          studentsCount: 0,
          deliveredCount: 0,
          isStudent: true,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.studentClassDetail,
              arguments: cls['id'],
            );
          },
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
        onTap: () => showJoinClassModal(context, onJoined: _loadClasses),
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