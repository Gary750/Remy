import 'package:flutter/material.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/config/app_theme.dart';
import 'package:remy/views/auth/login_screen.dart';
import 'package:remy/views/auth/register_screen.dart';
import 'package:remy/views/professor/dashboard_screen.dart';
import 'package:remy/views/professor/create_class_screen.dart';
import 'package:remy/views/professor/class_detail_screen.dart';
import 'package:remy/views/professor/create_assignment_screen.dart';
import 'package:remy/views/professor/student_recipe_screen.dart';
import 'package:remy/views/professor/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REMY',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.dashboard:
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case AppRoutes.createClass:
            return MaterialPageRoute(builder: (_) => const CreateClassScreen());
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case AppRoutes.classDetail:
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ClassDetailScreen(classId: args),
            );
          case AppRoutes.createAssignment:
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CreateAssignmentScreen(classId: args),
            );
          case AppRoutes.studentRecipe:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => StudentRecipeScreen(
                studentId: args['studentId'],
                classId: args['classId'],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Ruta no encontrada: ${settings.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}