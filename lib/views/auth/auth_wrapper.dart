// views/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/auth_provider.dart';
import 'package:remy/views/auth/login_screen.dart';
import 'package:remy/views/mobile/professor/dashboard_screen.dart';
import 'package:remy/views/student/my_classes_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🔍 AuthWrapper - isLoading: ${authProvider.isLoading}');
        print('🔍 AuthWrapper - isLoggedIn: ${authProvider.isLoggedIn}');
        print('🔍 AuthWrapper - currentUser: ${authProvider.currentUser?.fullName}');

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
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (!authProvider.isLoggedIn) {
          print('🔴 Usuario NO logueado - Mostrando LoginScreen');
          return const LoginScreen();
        }

        final user = authProvider.currentUser;
        print('🟢 Usuario logueado: ${user?.fullName}, rol: ${user?.role}');

        if (user?.role == 'profesor') {
          print('🟢 Es profesor - Mostrando ProfessorDashboard');
          return const ProfessorDashboardScreen();
        } else {
          print('🟢 Es estudiante - Mostrando StudentMyClassesScreen');
          return const StudentMyClassesScreen();
        }
      },
    );
  }
}