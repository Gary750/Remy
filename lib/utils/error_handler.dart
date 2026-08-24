import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Traduce cualquier objeto de error o excepción a un mensaje claro y amigable en español.
  static String translate(dynamic error) {
    if (error == null) return 'Ocurrió un error inesperado';

    if (error is AuthException) {
      return _translateAuthException(error);
    }

    if (error is PostgrestException) {
      return _translatePostgrestException(error);
    }

    if (error is StorageException) {
      return _translateStorageException(error);
    }

    if (error is SocketException) {
      return 'Error de conexión. Por favor verifica tu conexión a internet.';
    }

    if (error is TimeoutException) {
      return 'La solicitud tardó demasiado tiempo. Inténtalo de nuevo.';
    }

    if (error is FormatException) {
      return 'Formato de datos no válido.';
    }

    final String errStr = error.toString().toLowerCase();

    if (errStr.contains('socketexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('network request failed') ||
        errStr.contains('clientexception') ||
        errStr.contains('connection refused') ||
        errStr.contains('connection closed')) {
      return 'Error de conexión. Verifica tu acceso a internet e inténtalo de nuevo.';
    }

    if (errStr.contains('invalid login credentials') ||
        errStr.contains('invalid_credentials') ||
        errStr.contains('user not found')) {
      return 'Correo o contraseña incorrectos. Verifica tus datos.';
    }

    if (errStr.contains('user already registered') ||
        errStr.contains('email rate limit exceeded')) {
      return 'Este correo electrónico ya se encuentra registrado.';
    }

    if (errStr.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    if (errStr.contains('no hay sesión activa')) {
      return 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
    }

    // Limpiar prefijos de texto como Exception: o Error:
    String cleanMsg = error.toString();
    cleanMsg = cleanMsg.replaceAll(RegExp(r'^Exception:\s*'), '');
    cleanMsg = cleanMsg.replaceAll(RegExp(r'^Error:\s*'), '');

    // Si sigue conteniendo dump técnico de tipos de excepción, mostrar mensaje amigable por defecto
    if (cleanMsg.contains('Exception') ||
        cleanMsg.contains('Postgrest') ||
        cleanMsg.contains('AuthException') ||
        cleanMsg.contains('StorageException')) {
      return 'Ocurrió un problema al procesar tu solicitud. Inténtalo más tarde.';
    }

    return cleanMsg.isNotEmpty ? cleanMsg : 'Ocurrió un error inesperado.';
  }

  static String _translateAuthException(AuthException error) {
    final msg = error.message.toLowerCase();
    final code = error.statusCode?.toString() ?? '';

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos. Por favor verifica tus datos.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('user_already_exists')) {
      return 'Este correo electrónico ya está registrado. Intenta iniciar sesión.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Tu correo aún no está verificado. Revisa tu bandeja de entrada.';
    }
    if (msg.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (msg.contains('rate limit') || code == '429') {
      return 'Demasiados intentos. Por favor espera unos momentos e inténtalo de nuevo.';
    }
    if (msg.contains('same as old password')) {
      return 'La nueva contraseña debe ser diferente a la contraseña actual.';
    }

    return error.message.isNotEmpty
        ? error.message
        : 'Error de autenticación. Verifica tus datos.';
  }

  static String _translatePostgrestException(PostgrestException error) {
    final code = error.code ?? '';
    final msg = error.message.toLowerCase();

    if (code == '23505' || msg.contains('duplicate key')) {
      return 'Ya existe un registro con estos datos.';
    }
    if (code == '23503' || msg.contains('foreign key constraint')) {
      return 'No se puede realizar esta acción porque la información está vinculada a otros registros.';
    }
    if (code == '42P01') {
      return 'Error de base de datos. Póngase en contacto con soporte técnico.';
    }
    if (code == 'PGRST116') {
      return 'No se encontró la información solicitada.';
    }

    return 'Error en la base de datos. Por favor inténtalo nuevamente.';
  }

  static String _translateStorageException(StorageException error) {
    final msg = error.message.toLowerCase();
    final status = error.statusCode;

    if (status == '404' || msg.contains('not found')) {
      return 'No se encontró la imagen o el archivo.';
    }
    if (status == '413' || msg.contains('payload too large')) {
      return 'La imagen es demasiado grande. Elige una de menor peso.';
    }

    return 'Error al procesar el archivo o la imagen. Inténtalo de nuevo.';
  }
}
