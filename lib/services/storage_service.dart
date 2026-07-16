// lib/services/storage_service.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class StorageService {
  static const String recipesBucket = 'recipes_images';
  static const String avatarsBucket = 'avatars';

  /// Sube la imagen de una receta y devuelve la URL pública.
  Future<String> uploadRecipeImage(Uint8List bytes, String fileName) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final ext = _extensionFrom(fileName);
      final path =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}$ext';

      await supabase.storage.from(recipesBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from(recipesBucket).getPublicUrl(path);
    } catch (e) {
      throw 'Error al subir la imagen de la receta: $e';
    }
  }

  /// Sube la foto de perfil y devuelve la URL pública.
  /// Usa siempre el mismo nombre de archivo por usuario (upsert) para no
  /// acumular fotos viejas en el bucket.
  Future<String> uploadAvatar(Uint8List bytes, String fileName) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final ext = _extensionFrom(fileName);
      final path = '${user.id}/avatar$ext';

      await supabase.storage.from(avatarsBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Se agrega un query param con timestamp para evitar el cache de
      // la imagen anterior con el mismo nombre.
      final url = supabase.storage.from(avatarsBucket).getPublicUrl(path);
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw 'Error al subir la foto de perfil: $e';
    }
  }

  String _extensionFrom(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    return fileName.substring(dot).toLowerCase();
  }
}