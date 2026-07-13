import 'package:flutter/material.dart';
import 'package:remy/controllers/auth_controller.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = AuthController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? selectedRole; // Variable para el rol

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Regístrate para comenzar a usar REMY',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: nameController,
                      label: 'Nombre completo *',
                      hint: 'Tu nombre completo',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: emailController,
                      label: 'Correo electrónico *',
                      hint: 'ejemplo@correo.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Selector de Rol
                    // Dentro de lib/views/auth/register_screen.dart
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol *',
                        prefixIcon: Icon(Icons.badge, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        // El 'value' es lo que se manda a la base de datos (debe ir en minúsculas)
                        // El 'child' es el texto que ve el usuario en la pantalla (puede llevar mayúscula)
                        DropdownMenuItem(
                          value: 'profesor',
                          child: Text('Profesor'),
                        ),
                        DropdownMenuItem(
                          value: 'alumno',
                          child: Text('Alumno'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: passwordController,
                      label: 'Contraseña *',
                      hint: 'Mínimo 6 caracteres',
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
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: confirmPasswordController,
                      label: 'Confirmar contraseña *',
                      hint: 'Repite tu contraseña',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      obscureText: obscureConfirmPassword,
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Registrarse',
                      onPressed: _register,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: const Text('Inicia sesión'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    // 1. Validar campos vacíos incluyendo el rol
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Validar formato de correo
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo electrónico válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Validar contraseñas
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Pasamos el rol seleccionado al controlador
      await authController.register(
        nameController.text,
        emailController.text.trim(),
        passwordController.text,
        selectedRole!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
