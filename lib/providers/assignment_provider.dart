import 'package:flutter/material.dart';
import 'package:remy/models/assignment_model.dart';
import 'package:remy/services/supabase_service.dart';

class AssignmentProvider extends ChangeNotifier {
  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _error;
  AssignmentModel? _activeAssignment;

  final SupabaseService _supabase = SupabaseService();

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AssignmentModel? get activeAssignment => _activeAssignment;

  Future<void> loadAssignments(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.getClassAssignments(classId);
      _assignments = data.map((e) => AssignmentModel.fromJson(e)).toList();

      try {
        _activeAssignment = _assignments.firstWhere((a) => a.isActive);
      } catch (e) {
        _activeAssignment = null;
      }
    } catch (e) {
      _error = 'Error al cargar entregas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssignment({
    required String classId,
    required String title,
    required String recipeType, // 'Comida', 'Bebida' o 'Ambos'
    required DateTime dueDate,
    String? instructions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.createAssignment(
        classId: classId,
        title: title,
        recipeType: recipeType, // ← CORREGIDO
        dueDate: dueDate,
        instructions: instructions,
      );

      final newAssignment = AssignmentModel.fromJson(data);
      _assignments.insert(0, newAssignment);

      if (newAssignment.isActive) {
        _activeAssignment = newAssignment;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear la entrega: $e';
      print('❌ Error: $e');
      return false;
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