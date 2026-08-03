import 'package:flutter/material.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/student/my_classes_screen.dart';
import 'package:remy/views/student/student_recipe_book_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudentMyClassesScreen(),
    StudentRecipeBookScreen(),
  ];

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Mis Clases';
      case 1:
        return 'Mi Recetario';
      default:
        return 'Remy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.studentProfile);
            },
            tooltip: 'Mi Perfil',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: const Color(0xFFE65100),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Mis Clases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Mi Recetario',
          ),
        ],
      ),
    );
  }
}
