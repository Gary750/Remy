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
    print('🔄 loadCurrentUser - Iniciando...');
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.supabase.auth.currentSession;

      if (session != null) {
        print('🔄 Sesión encontrada para: ${session.user.email}');
        await loadUserProfile(session.user.id);
      } else {
        print('🔄 No hay sesión activa');
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Error loading current user: $e');
      _currentUser = null;
      _error = 'Error al cargar el usuario';
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🔄 loadCurrentUser - Finalizado, isLoggedIn: $isLoggedIn');
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      print('📥 loadUserProfile - Buscando perfil para userId: $userId');
      final data = await _supabase.getProfile(userId);

      if (data != null) {
        _currentUser = ProfileModel.fromJson(data);
        _error = null;
        print('✅ Perfil cargado: ${_currentUser?.fullName}, rol: ${_currentUser?.role}');
      } else {
        _error = 'No se encontró el perfil del usuario';
        _currentUser = null;
        print('❌ $_error');
      }
    } catch (e) {
      _error = 'Error al cargar el perfil';
      _currentUser = null;
      print('❌ Error loading profile: $e');
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    print('🔐 signIn - Iniciando login...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 Intentando login con: $email');
      
      final response = await _supabase.signIn(email, password);
      print('🔐 signIn - Respuesta recibida');

      if (response.user != null) {
        print('✅ Usuario autenticado: ${response.user!.id}');
        await loadUserProfile(response.user!.id);
        
        if (_currentUser != null) {
          print('✅ Login exitoso: ${_currentUser!.fullName}');
          print('✅ Rol: ${_currentUser!.role}');
          _isLoading = false;
          notifyListeners();
          print('✅ notifyListeners() llamado después del login');
          return true;
        } else {
          _error = 'No se pudo cargar el perfil del usuario';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = '❌ Credenciales incorrectas. Verifica tu correo y contraseña.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      
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
    print('📝 signUp - Iniciando registro...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Intentando registrar: $email');
      print('📝 Nombre: $fullName');
      print('📝 Rol: $role');
      
      final response = await _supabase.signUp(email, password, fullName, role);
      print('📝 Respuesta recibida');

      if (response.user != null) {
        print('✅ Usuario creado: ${response.user!.id}');
        await loadUserProfile(response.user!.id);
        
        if (_currentUser != null) {
          print('✅ Registro exitoso: ${_currentUser!.fullName}');
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
        _error = '❌ Error al registrar usuario. Intenta de nuevo.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user already registered')) {
        _error = '❌ Este correo ya está registrado';
      } else if (errorStr.contains('password')) {
        _error = '❌ La contraseña debe tener al menos 6 caracteres';
      } else {
        _error = '❌ Error al registrar. Intenta de nuevo.';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    print('🔴 signOut - Cerrando sesión...');
    try {
      await _supabase.signOut();
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}