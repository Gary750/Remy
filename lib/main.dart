import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Configuración
import 'package:remy/config/app_routes.dart';
import 'package:remy/config/app_theme.dart';

// Vistas de Autenticación
import 'package:remy/views/auth/login_screen.dart';
import 'package:remy/views/auth/register_screen.dart';

// Vistas del Profesor
import 'package:remy/views/professor/dashboard_screen.dart';
import 'package:remy/views/professor/create_class_screen.dart';
import 'package:remy/views/professor/class_detail_screen.dart';
import 'package:remy/views/professor/create_assignment_screen.dart';
import 'package:remy/views/professor/student_recipe_screen.dart';
import 'package:remy/views/professor/profile_screen.dart';

// Vistas del Alumno
import 'package:remy/views/student/my_classes_screen.dart';
import 'package:remy/views/student/student_class_detail_screen.dart';
import 'package:remy/views/student/upload_recipe_screen.dart';
import 'package:remy/views/student/my_recipes_screen.dart';
import 'package:remy/views/student/my_grades_screen.dart';
import 'package:remy/views/student/search_recipes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
          // Ruta raíz que Flutter genera automáticamente junto con
          // initialRoute (ver Navigator.defaultGenerateInitialRoutes).
          // Sin este caso, un "pop" que llegue hasta el fondo de la pila
          // cae en el default y muestra "Ruta no encontrada: /".
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          // Autenticación
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          // Profesor
          case AppRoutes.dashboard:
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case AppRoutes.createClass:
            return MaterialPageRoute(builder: (_) => const CreateClassScreen());
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case AppRoutes.classDetail:
            final args = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => ClassDetailScreen(classId: args));
          case AppRoutes.createAssignment:
            final args = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => CreateAssignmentScreen(classId: args));
          case AppRoutes.studentRecipe:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => StudentRecipeScreen(
                studentId: args['studentId'],
                classId: args['classId'],
              ),
            );

          // Alumno
          case AppRoutes.studentDashboard:
            return MaterialPageRoute(builder: (_) => const MyClassesScreen());
          case AppRoutes.studentClassDetail:
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => StudentClassDetailScreen(classId: args),
            );
          case AppRoutes.uploadRecipe:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => UploadRecipeScreen(
                assignmentId: args['assignmentId'],
                classId: args['classId'],
                recipeType: args['recipeType'],
              ),
            );
          case AppRoutes.myRecipes:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => MyRecipesScreen(
                assignmentId: args?['assignmentId'],
                classId: args?['classId'],
              ),
            );
          case AppRoutes.myGrades:
            return MaterialPageRoute(builder: (_) => const MyGradesScreen());
          case AppRoutes.searchRecipes:
            return MaterialPageRoute(builder: (_) => const SearchRecipesScreen());

          // Fallback
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Ruta no encontrada: ${settings.name}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        child: const Text('Volver al Inicio'),
                      )
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