import 'package:flutter/material.dart';
// import 'package:remy/controllers/auth_controller.dart'; // TODO: Descomentar
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // TODO: Inicializar AuthController
  // final AuthController authController = AuthController();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? selectedRole;

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
                    
                    // Nombre
                    CustomTextField(
                      controller: nameController,
                      label: 'Nombre completo *',
                      hint: 'Tu nombre completo',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    CustomTextField(
                      controller: emailController,
                      label: 'Correo electrónico *',
                      hint: 'ejemplo@correo.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // Rol
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol *',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'professor', child: Text('Profesor')),
                        DropdownMenuItem(value: 'student', child: Text('Estudiante')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Contraseña
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
                    
                    // Confirmar contraseña
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
                    
                    // Register button
                    CustomButton(
                      text: 'Registrarse',
                      onPressed: _register,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
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
    // Validaciones
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

    // TODO: Conectar con Supabase
    /*
    try {
      await authController.register(
        nameController.text,
        emailController.text,
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
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    */

    // Simulación (eliminar después)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Cuenta creada exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}