import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/auth_provider.dart';
import 'package:remy/providers/class_provider.dart';
import 'package:remy/providers/assignment_provider.dart';
import 'package:remy/providers/enrollment_provider.dart';
import 'package:remy/services/supabase_service.dart';
import 'package:remy/views/auth/login_screen.dart';
import 'package:remy/views/mobile/professor/dashboard_screen.dart';

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
          '/login': (context) => const LoginScreen(),
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

    // ✅ Si está cargando, mostrar loading
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFE65100),
              ),
              SizedBox(height: 16),
              Text(
                'Cargando...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Si no está logueado, mostrar login
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }

    // ✅ Si está logueado, mostrar dashboard según rol
    final user = authProvider.currentUser;
    if (user?.role == 'profesor') {
      return const ProfessorDashboardScreen();
    } else {
      // Temporal - después se crea el dashboard de estudiante
      return const ProfessorDashboardScreen();
    }
  }
}