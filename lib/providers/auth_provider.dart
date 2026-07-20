import 'package:flutter/material.dart';
import 'package:remy/models/profile_model.dart';
import 'package:remy/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  ProfileModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  final SupabaseService _supabase = SupabaseService();

  ProfileModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.supabase.auth.currentSession;

      if (session != null) {
        await loadUserProfile(session.user.id);
      }
    } catch (e) {
      print('Error loading current user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      final data = await _supabase.getProfile(userId);

      if (data != null) {
        _currentUser = ProfileModel.fromJson(data);
        _error = null;
      } else {
        _error = 'No se encontró el perfil del usuario';
        _currentUser = null;
      }
    } catch (e) {
      _error = 'Error al cargar el perfil';
      _currentUser = null;
      print('Error loading profile: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 Intentando login con: $email');
      
      final response = await _supabase.signIn(email, password);

      if (response.user != null) {
        await loadUserProfile(response.user!.id);
        
        if (_currentUser != null) {
          print('✅ Login exitoso: ${_currentUser!.fullName}');
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'No se pudo cargar el perfil del usuario';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      
      // ✅ Mostrar error específico según el tipo de error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid credentials') || 
          errorStr.contains('invalid login') ||
          errorStr.contains('user not found')) {
        _error = '❌ Correo o contraseña incorrectos';
      } else if (errorStr.contains('email not confirmed')) {
        _error = '❌ Correo no verificado. Revisa tu bandeja de entrada.';
      } else {
        _error = '❌ Error al iniciar sesión. Intenta de nuevo.';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.signUp(email, password, fullName, role);

      if (response.user != null) {
        await loadUserProfile(response.user!.id);
        
        if (_currentUser != null) {
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'No se pudo crear el perfil del usuario';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Error al registrar usuario. Intenta de nuevo.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      _error = 'Error al registrar: ${e.toString().replaceFirst('Exception:', '')}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.signOut();
      _currentUser = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}