// lib/controllers/assignment_controller.dart
import '../config/supabase_client.dart';

class AssignmentController {
  /// Datos de una clase por id (usado en la cabecera de student_class_detail).
  Future<Map<String, dynamic>> getClassDetail(String classId) async {
    try {
      final response =
          await supabase.from('classes').select().eq('id', classId).single();
      return response;
    } catch (e) {
      throw 'Error al cargar la clase: $e';
    }
  }

  /// Entregas (assignments) de una clase, enriquecidas para el alumno
  /// autenticado con si ya entregó (existe receta suya para esa entrega)
  /// y su calificación (si ya fue calificada).
  ///
  /// NOTA: 'assignments' no tiene FK directa a 'recipes' ni a 'grades' desde
  /// PostgREST en el sentido que necesitamos (uno-a-muchos por alumno), así
  /// que se resuelven con queries separadas y se combinan en Dart.
  Future<List<Map<String, dynamic>>> getAssignmentsForStudent(
      String classId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final assignmentsResponse = await supabase
          .from('assignments')
          .select()
          .eq('class_id', classId)
          .order('due_date', ascending: true);

      final assignments = List<Map<String, dynamic>>.from(assignmentsResponse);
      if (assignments.isEmpty) return [];

      final assignmentIds = assignments.map((a) => a['id']).toList();

      // Recetas propias para estas entregas -> determina "entregado"
      final recipesResponse = await supabase
          .from('recipes')
          .select('assignment_id')
          .eq('student_id', user.id)
          .inFilter('assignment_id', assignmentIds);
      final deliveredSet = List<Map<String, dynamic>>.from(recipesResponse)
          .map((r) => r['assignment_id'])
          .toSet();

      // Calificaciones propias para estas entregas
      final gradesResponse = await supabase
          .from('grades')
          .select('assignment_id, stars')
          .eq('student_id', user.id)
          .inFilter('assignment_id', assignmentIds);
      final gradesMap = {
        for (final g in List<Map<String, dynamic>>.from(gradesResponse))
          g['assignment_id']: g['stars']
      };

      return assignments.map((a) {
        return {
          ...a,
          'due_date': DateTime.parse(a['due_date']),
          'delivered': deliveredSet.contains(a['id']),
          'stars': gradesMap[a['id']],
        };
      }).toList();
    } catch (e) {
      throw 'Error al cargar las entregas: $e';
    }
  }
}