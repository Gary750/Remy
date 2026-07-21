import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/auth_provider.dart';
import 'package:remy/providers/class_provider.dart';
import 'package:remy/providers/assignment_provider.dart';
import 'package:remy/providers/enrollment_provider.dart';
import 'package:remy/services/supabase_service.dart';

// ==================== PANTALLAS DE AUTENTICACIÓN ====================
import 'package:remy/views/auth/login_screen.dart';
import 'package:remy/views/auth/register_screen.dart';

// ==================== PANTALLAS DE PROFESOR ====================
import 'package:remy/views/mobile/professor/dashboard_screen.dart';
import 'package:remy/views/mobile/professor/create_class_screen.dart';
import 'package:remy/views/mobile/professor/class_detail_screen.dart';
import 'package:remy/views/mobile/professor/create_assignment_screen.dart';
import 'package:remy/views/mobile/professor/profile_screen.dart';
import 'package:remy/views/mobile/professor/student_recipe_screen.dart';

// ==================== PANTALLAS DE ESTUDIANTE ====================
import 'package:remy/views/student/my_classes_screen.dart';
import 'package:remy/views/student/student_class_detail_screen.dart';
import 'package:remy/views/student/upload_recipe_screen.dart';
import 'package:remy/views/student/my_recipes_screen.dart';
import 'package:remy/views/student/search_recipes_screen.dart';
import 'package:remy/views/student/my_grades_screen.dart';

// ==================== CONFIGURACIÓN DE RUTAS ====================
import 'package:remy/config/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final supabaseService = SupabaseService();
    await supabaseService.init();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('❌ Error al inicializar Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadCurrentUser(),
        ),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
      ],
      child: MaterialApp(
        title: 'Remy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFE65100),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE65100),
            primary: const Color(0xFFE65100),
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE65100),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          // ========== AUTENTICACIÓN ==========
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),

          // ========== PROFESOR ==========
          AppRoutes.professorDashboard: (context) => const ProfessorDashboardScreen(),
          AppRoutes.professorCreateClass: (context) => const CreateClassScreen(),
          AppRoutes.professorProfile: (context) => const ProfessorProfileScreen(),

          // ========== ESTUDIANTE ==========
          AppRoutes.studentDashboard: (context) => const StudentMyClassesScreen(),
          AppRoutes.studentMyRecipes: (context) => const MyRecipesScreen(),
          AppRoutes.studentSearchRecipes: (context) => const SearchRecipesScreen(),
          AppRoutes.studentMyGrades: (context) => const MyGradesScreen(),
          AppRoutes.studentProfile: (context) => const ProfessorProfileScreen(), // Reutiliza perfil
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // ========== PROFESOR ==========
            case AppRoutes.professorClassDetail:
              final classId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ClassDetailScreen(
                  classId: classId,
                  className: '',
                ),
              );
            case AppRoutes.professorCreateAssignment:
              final classId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => CreateAssignmentScreen(classId: classId),
              );
            case AppRoutes.professorStudentRecipe:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => StudentRecipeScreen(
                  studentId: args['studentId'],
                  assignmentId: args['assignmentId'],
                  classId: args['classId'] ?? '',
                  studentName: args['studentName'] ?? 'Estudiante',
                ),
              );

            // ========== ESTUDIANTE ==========
            case AppRoutes.studentClassDetail:
              final classId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => StudentClassDetailScreen(classId: classId),
              );
            case AppRoutes.studentUploadRecipe:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => UploadRecipeScreen(
                  assignmentId: args['assignmentId'],
                  classId: args['classId'],
                  recipeType: args['recipeType'] ?? 'Ambos',
                ),
              );
            case AppRoutes.studentMyRecipes:
              // Si se pasan argumentos (ej. assignmentId, classId)
              if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => MyRecipesScreen(
                    assignmentId: args['assignmentId'],
                    classId: args['classId'],
                  ),
                );
              }
              // Sin argumentos, simplemente muestra todas las recetas
              return MaterialPageRoute(
                builder: (context) => const MyRecipesScreen(),
              );

            default:
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Ruta no encontrada'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFE65100)),
              SizedBox(height: 16),
              Text('Cargando...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }

    final user = authProvider.currentUser;
    if (user?.role == 'profesor') {
      return const ProfessorDashboardScreen();
    } else {
      return const StudentMyClassesScreen();
    }
  }
}