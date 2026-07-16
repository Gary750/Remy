// lib/controllers/student_controller.dart
import '../config/supabase_client.dart';

class StudentController {
  /// Une al alumno autenticado a una clase mediante su código de invitación.
  /// La búsqueda del código no distingue mayúsculas/minúsculas.
  Future<Map<String, dynamic>> joinClass(String joinCode) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final code = joinCode.trim().toUpperCase();

      // 1. Buscar la clase por su código
      final classData = await supabase
          .from('classes')
          .select()
          .eq('join_code', code)
          .maybeSingle();

      if (classData == null) {
        throw 'No existe ninguna clase con ese código';
      }

      // 2. Verificar que no esté ya inscrito
      final existing = await supabase
          .from('enrollments')
          .select('id')
          .eq('class_id', classData['id'])
          .eq('student_id', user.id)
          .maybeSingle();

      if (existing != null) {
        throw 'Ya estás inscrito en esta clase';
      }

      // 3. Crear la inscripción
      await supabase.from('enrollments').insert({
        'class_id': classData['id'],
        'student_id': user.id,
      });

      return classData;
    } catch (e) {
      throw e is String ? e : 'Error al unirse a la clase: $e';
    }
  }

  /// Clases en las que el alumno autenticado está inscrito.
  Future<List<Map<String, dynamic>>> getMyClasses() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final response = await supabase
          .from('enrollments')
          .select('joined_at, classes(*)')
          .eq('student_id', user.id)
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map((e) => Map<String, dynamic>.from(e['classes']))
          .toList();
    } catch (e) {
      throw 'Error al cargar tus clases: $e';
    }
  }

  /// Calificaciones del alumno agrupadas por clase, para "Mis Calificaciones".
  /// Devuelve una lista de mapas: {class_id, subject, group_name, grades: [...]}
  Future<List<Map<String, dynamic>>> getMyGrades() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      // Trae todas las entregas de las clases del alumno junto con su
      // receta (si la subió) y su calificación (si ya fue calificada).
      final response = await supabase
          .from('assignments')
          .select('''
            id,
            title,
            classes!inner(id, subject, group_name, enrollments!inner(student_id)),
            recipes(id, name, student_id),
            grades(stars, student_id)
          ''')
          .eq('classes.enrollments.student_id', user.id);

      final Map<String, Map<String, dynamic>> grouped = {};

      for (final row in List<Map<String, dynamic>>.from(response)) {
        final classInfo = row['classes'];
        final classId = classInfo['id'];

        // Filtra solo la receta y calificación que pertenecen a este alumno
        final recipes = List<Map<String, dynamic>>.from(row['recipes'] ?? []);
        final myRecipe = recipes.firstWhere(
          (r) => r['student_id'] == user.id,
          orElse: () => {},
        );

        final grades = List<Map<String, dynamic>>.from(row['grades'] ?? []);
        final myGrade = grades.firstWhere(
          (g) => g['student_id'] == user.id,
          orElse: () => {},
        );

        grouped.putIfAbsent(classId, () => {
              'class_id': classId,
              'subject': classInfo['subject'],
              'group_name': classInfo['group_name'],
              'grades': <Map<String, dynamic>>[],
            });

        grouped[classId]!['grades'].add({
          'assignment_title': row['title'],
          'recipe_name': myRecipe.isNotEmpty ? myRecipe['name'] : null,
          'stars': myGrade.isNotEmpty ? myGrade['stars'] : null,
        });
      }

      return grouped.values.toList();
    } catch (e) {
      throw 'Error al cargar tus calificaciones: $e';
    }
  }
}