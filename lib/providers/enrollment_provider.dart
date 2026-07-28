import 'package:flutter/material.dart';
import 'package:remy/services/supabase_service.dart';

class EnrollmentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;
  String? _error;

  final SupabaseService _supabase = SupabaseService();

  List<Map<String, dynamic>> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudents(String classId) async {
    _isLoading = true;
    _error = null;
    // Postergar la notificación para evitar conflictos si se llama durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isLoading) notifyListeners();
    });

    try {
      _students = await _supabase.getStudentsByClass(classId);
    } catch (e) {
      _error = 'Error al cargar alumnos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}