import 'package:flutter/material.dart';
import 'package:remy/controllers/auth_controller.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = AuthController();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'REMY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text(
                    'Gestión de Recetarios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomTextField(
                    controller: emailController,
                    label: 'Correo electrónico',
                    hint: 'ejemplo@correo.com',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    hint: 'Ingresa tu contraseña',
                    prefixIcon: Icons.lock,
                    suffixIcon: obscurePassword 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                    onSuffixPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    obscureText: obscurePassword,
                  ),
                  /*TODO : Implementar la funcionalidad de recuperación de contraseña
                  const SizedBox(height: 8),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  */
                  const SizedBox(height: 16),
                  
                  CustomButton(
                    text: 'Iniciar Sesión',
                    onPressed: _login,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authController.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      final role = response['role'];
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido! Iniciaste como $role'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirección dinámica basada en el rol
      if (role == 'profesor') {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        // Asegúrate de tener una ruta para el alumno en tu app_routes.dart
        // Por ahora redirigimos al dashboard general si no existe una vista específica
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}