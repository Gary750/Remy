import 'package:remy/services/supabase_service.dart';

class StudentController {
  final SupabaseService _supabase = SupabaseService();

  // ==================== CLASES ====================
  Future<List<Map<String, dynamic>>> getMyClasses() async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return [];

      final userId = session.user.id;

      final response = await _supabase.supabase
          .from('enrollments')
          .select('''
            class_id,
            classes!inner (
              id,
              subject,
              term,
              group_name,
              join_code,
              professor_id
            )
          ''')
          .eq('student_id', userId);

      final classes = (response as List).map((e) {
        final classData = e['classes'] as Map<String, dynamic>;
        return {
          'id': classData['id'],
          'subject': classData['subject'],
          'term': classData['term'],
          'group_name': classData['group_name'],
          'join_code': classData['join_code'],
          'professor_id': classData['professor_id'],
        };
      }).toList();

      return List<Map<String, dynamic>>.from(classes);
    } catch (e) {
      print('Error al obtener clases del estudiante: $e');
      return [];
    }
  }

  Future<bool> joinClass(String code) async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return false;

      // Buscar la clase por código
      final classResponse = await _supabase.supabase
          .from('classes')
          .select('id')
          .eq('join_code', code.toUpperCase())
          .maybeSingle();

      if (classResponse == null) return false;

      final classId = classResponse['id'];

      // Verificar si ya está inscrito
      final existing = await _supabase.supabase
          .from('enrollments')
          .select()
          .eq('class_id', classId)
          .eq('student_id', session.user.id)
          .maybeSingle();

      if (existing != null) return false;

      // Inscribir al estudiante
      await _supabase.supabase.from('enrollments').insert({
        'class_id': classId,
        'student_id': session.user.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error al unirse a clase: $e');
      return false;
    }
  }

  // ==================== RECETAS ====================
  Future<List<Map<String, dynamic>>> getMyRecipes() async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return [];

      final userId = session.user.id;

      final response = await _supabase.supabase
          .from('recipes')
          .select('''
            *,
            assignments!inner (
              title,
              class_id,
              classes!inner (
                subject,
                term,
                group_name
              )
            )
          ''')
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener recetas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRecipeDetail(String recipeId) async {
    try {
      final response = await _supabase.supabase
          .from('recipes')
          .select('''
            *,
            assignments!inner (
              title,
              class_id,
              classes!inner (
                subject,
                term,
                group_name
              )
            )
          ''')
          .eq('id', recipeId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener detalle de receta: $e');
      return null;
    }
  }

  Future<bool> uploadRecipe({
    required String assignmentId,
    required String name,
    required String type,
    String? country,
    String? region,
    String? imageUrl,
    String? cookingStyle,
    String? miseEnPlace,
    String? ingredients,
    String? sauce,
    String? procedure,
  }) async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return false;

      await _supabase.supabase.from('recipes').insert({
        'assignment_id': assignmentId,
        'student_id': session.user.id,
        'name': name,
        'type': type,
        'country': country ?? '',
        'region': region ?? '',
        'image_url': imageUrl ?? '',
        'cooking_style': cookingStyle ?? '',
        'mise_en_place': miseEnPlace ?? '',
        'ingredients': ingredients ?? '',
        'sauce': sauce ?? '',
        'procedure': procedure ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error al subir receta: $e');
      return false;
    }
  }

  // ==================== CALIFICACIONES ====================
  Future<List<Map<String, dynamic>>> getMyGrades() async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return [];

      final userId = session.user.id;

      final response = await _supabase.supabase
          .from('recipes')
          .select('''
            id,
            name,
            type,
            created_at,
            assignments!inner (
              id,
              title,
              class_id,
              classes!inner (
                subject,
                term,
                group_name
              )
            ),
            grades!left (
              score,
              feedback,
              graded_at
            )
          ''')
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener calificaciones: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getGradeDetail(String recipeId) async {
    try {
      final response = await _supabase.supabase
          .from('recipes')
          .select('''
            *,
            assignments!inner (
              title,
              class_id,
              classes!inner (
                subject,
                term,
                group_name
              )
            ),
            grades!left (
              score,
              feedback,
              graded_at
            )
          ''')
          .eq('id', recipeId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener detalle de calificación: $e');
      return null;
    }
  }

  // ==================== BÚSQUEDA DE RECETAS ====================
  Future<List<Map<String, dynamic>>> searchRecipes({
    String? query,
    String? type,
    String? country,
    String? cookingStyle,
  }) async {
    try {
      var request = _supabase.supabase
          .from('recipes')
          .select('''
            *,
            profiles!inner (
              full_name
            ),
            assignments!inner (
              title,
              classes!inner (
                subject
              )
            )
          ''');

      if (query != null && query.isNotEmpty) {
        request = request.ilike('name', '%$query%');
      }

      if (type != null && type.isNotEmpty) {
        request = request.eq('type', type);
      }

      if (country != null && country.isNotEmpty) {
        request = request.eq('country', country);
      }

      if (cookingStyle != null && cookingStyle.isNotEmpty) {
        request = request.eq('cooking_style', cookingStyle);
      }

      final response = await request.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al buscar recetas: $e');
      return [];
    }
  }

  // ==================== DETALLE DE CLASE (ESTUDIANTE) ====================
  Future<Map<String, dynamic>?> getClassDetail(String classId) async {
    try {
      final response = await _supabase.supabase
          .from('classes')
          .select('''
            *,
            assignments (
              *,
              recipes (
                id,
                student_id,
                name,
                created_at,
                grades (
                  score
                )
              )
            ),
            enrollments (
              student_id,
              profiles!inner (
                full_name,
                email
              )
            )
          ''')
          .eq('id', classId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener detalle de clase: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getClassAssignments(String classId) async {
    try {
      final response = await _supabase.supabase
          .from('assignments')
          .select('''
            *,
            recipes (
              id,
              student_id,
              created_at,
              grades (
                score
              )
            )
          ''')
          .eq('class_id', classId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener entregas de clase: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMySubmission({
    required String assignmentId,
  }) async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return null;

      final response = await _supabase.supabase
          .from('recipes')
          .select('''
            *,
            grades (
              score,
              feedback,
              graded_at
            )
          ''')
          .eq('assignment_id', assignmentId)
          .eq('student_id', session.user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener mi entrega: $e');
      return null;
    }
  }

  // ==================== SUBIR RECETARIO COMPLETO ====================
  Future<bool> submitRecipes({
    required String assignmentId,
    required List<Map<String, dynamic>> recipes,
  }) async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return false;

      // Eliminar recetas existentes (si las hay)
      await _supabase.supabase
          .from('recipes')
          .delete()
          .eq('assignment_id', assignmentId)
          .eq('student_id', session.user.id);

      // Insertar nuevas recetas
      for (final recipe in recipes) {
        await _supabase.supabase.from('recipes').insert({
          'assignment_id': assignmentId,
          'student_id': session.user.id,
          'name': recipe['name'] ?? '',
          'type': recipe['type'] ?? 'Comida',
          'country': recipe['country'] ?? '',
          'region': recipe['region'] ?? '',
          'image_url': recipe['image_url'] ?? '',
          'cooking_style': recipe['cooking_style'] ?? '',
          'mise_en_place': recipe['mise_en_place'] ?? '',
          'ingredients': recipe['ingredients'] ?? '',
          'sauce': recipe['sauce'] ?? '',
          'procedure': recipe['procedure'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      print('Error al enviar recetario: $e');
      return false;
    }
  }
}