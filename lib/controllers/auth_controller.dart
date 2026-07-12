// lib/controllers/auth_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class AuthController {
  
  // Registro de usuario actualizado
  Future<AuthResponse> register(String name, String email, String password, String role) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'role': role, // Enviamos el rol que el usuario seleccionó en la UI
        },
      );
      return response;
    } catch (e) {
      throw 'Error al registrar: $e';
    }
  }

  // Inicio de sesión (se queda igual)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) throw 'Usuario no encontrado';

      final userData = await supabase
          .from('profiles')
          .select('role')
          .eq('id', response.user!.id)
          .single();

      return {
        'user': response.user,
        'role': userData['role'],
      };
    } catch (e) {
      throw 'Credenciales incorrectas o error de conexión.';
    }
  }

  // Cerrar sesión (se queda igual)
  Future<void> logout() async {
    await supabase.auth.signOut();
  }  
}