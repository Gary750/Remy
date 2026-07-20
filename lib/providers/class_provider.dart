import 'package:flutter/material.dart';
import 'package:remy/models/class_model.dart';
import 'package:remy/services/supabase_service.dart';

class ClassProvider extends ChangeNotifier {
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;

  final SupabaseService _supabase = SupabaseService();

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClasses(String professorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.getProfessorClasses(professorId);
      _classes = data.map((e) => ClassModel.fromJson(e)).toList();
      
      _classes.sort((a, b) {
        final aTerm = int.tryParse(a.term.replaceAll('°', '')) ?? 0;
        final bTerm = int.tryParse(b.term.replaceAll('°', '')) ?? 0;
        return aTerm.compareTo(bTerm);
      });
      
      print('✅ Clases cargadas con conteo real:');
      for (var cls in _classes) {
        print('📚 ${cls.subject} - Alumnos: ${cls.studentCount}');
      }
      
    } catch (e) {
      _error = 'Error al cargar clases: $e';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass({
    required String professorId,
    required String subject,
    required String term,
    required String groupName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabase.createClass(
        professorId: professorId,
        subject: subject,
        term: term,
        groupName: groupName,
      );

      final newClass = ClassModel.fromJson(data);
      
      final count = await _supabase.getStudentCountByClass(newClass.id);
      final classWithCount = ClassModel(
        id: newClass.id,
        professorId: newClass.professorId,
        subject: newClass.subject,
        term: newClass.term,
        groupName: newClass.groupName,
        joinCode: newClass.joinCode,
        createdAt: newClass.createdAt,
        studentCount: count,
      );
      
      _classes.insert(0, classWithCount);
      
      _classes.sort((a, b) {
        final aTerm = int.tryParse(a.term.replaceAll('°', '')) ?? 0;
        final bTerm = int.tryParse(b.term.replaceAll('°', '')) ?? 0;
        return aTerm.compareTo(bTerm);
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear la clase: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStudentCount(String classId) async {
    try {
      final count = await _supabase.getStudentCountByClass(classId);
      final index = _classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        _classes[index] = ClassModel(
          id: _classes[index].id,
          professorId: _classes[index].professorId,
          subject: _classes[index].subject,
          term: _classes[index].term,
          groupName: _classes[index].groupName,
          joinCode: _classes[index].joinCode,
          createdAt: _classes[index].createdAt,
          studentCount: count,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar conteo de alumnos: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}