// lib/controllers/profile_controller.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';
import '../services/storage_service.dart';

class ProfileController {
  final StorageService storageService = StorageService();

  /// Trae el perfil del usuario autenticado (tabla profiles) + su email
  /// (que vive en auth.users, no en profiles).
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final profile =
          await supabase.from('profiles').select().eq('id', user.id).single();

      return {
        ...profile,
        'email': user.email,
      };
    } catch (e) {
      throw 'Error al cargar el perfil: $e';
    }
  }

  /// Actualiza el nombre completo del usuario.
  Future<void> updateName(String fullName) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      await supabase
          .from('profiles')
          .update({'full_name': fullName})
          .eq('id', user.id);
    } catch (e) {
      throw 'Error al actualizar el nombre: $e';
    }
  }

  /// Sube una nueva foto de perfil y actualiza avatar_url en profiles.
  /// Devuelve la nueva URL para reflejarla de inmediato en pantalla.
  Future<String> updateAvatar(Uint8List bytes, String fileName) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final url = await storageService.uploadAvatar(bytes, fileName);

      await supabase
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', user.id);

      return url;
    } catch (e) {
      throw 'Error al actualizar la foto de perfil: $e';
    }
  }

  /// Cambia la contraseña, verificando primero la contraseña actual
  /// (Supabase no valida esto por sí solo al usar updateUser).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null || user.email == null) throw 'No hay sesión activa';

      // Re-autentica con la contraseña actual para confirmarla.
      try {
        await supabase.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
      } catch (_) {
        throw 'La contraseña actual es incorrecta';
      }

      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw e is String ? e : 'Error al cambiar la contraseña: $e';
    }
  }
}