import 'package:flutter/material.dart';
import 'package:remy/controllers/student_controller.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/models/class_model.dart';
import 'package:remy/views/shared/responsive_layout.dart';
import 'package:remy/views/shared/widgets/class_card.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'join_class_screen.dart';

class StudentMyClassesScreen extends StatefulWidget {
  const StudentMyClassesScreen({super.key});

  @override
  State<StudentMyClassesScreen> createState() => _StudentMyClassesScreenState();
}

class _StudentMyClassesScreenState extends State<StudentMyClassesScreen> {
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

  void showJoinClassModal(BuildContext context, {required VoidCallback onJoined}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => JoinClassScreen(onJoined: onJoined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.studentProfile);
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
              Row(
                children: [
                  Icon(Icons.school, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Clases en las que estás inscrito',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
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
      itemCount: classes.length + 1,
      itemBuilder: (context, index) {
        if (index == classes.length) {
          return _buildJoinAnotherClassCard();
        }

        final cls = classes[index];
        
        final classModel = ClassModel(
          id: cls['id'] ?? '',
          professorId: cls['professor_id'] ?? '',
          subject: cls['subject'] ?? '',
          term: cls['term'] ?? '',
          groupName: cls['group_name'] ?? '',
          joinCode: cls['join_code'] ?? '',
          createdAt: DateTime.now(),
          studentCount: 0,
        );

        return ClassCard(
          classModel: classModel,
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