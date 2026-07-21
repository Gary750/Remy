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

      final classResponse = await _supabase.supabase
          .from('classes')
          .select('id')
          .eq('join_code', code.toUpperCase())
          .maybeSingle();

      if (classResponse == null) return false;

      final classId = classResponse['id'];

      final existing = await _supabase.supabase
          .from('enrollments')
          .select()
          .eq('class_id', classId)
          .eq('student_id', session.user.id)
          .maybeSingle();

      if (existing != null) return false;

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
  // FIX: 'grades' no tiene columnas score/feedback/graded_at -- el schema
  // real solo tiene 'stars' (int 1-5). Tampoco existe una FK directa de
  // 'grades' hacia 'recipes' para poder usar un embed anidado de PostgREST
  // (grades se relaciona por (assignment_id, student_id)), así que se
  // resuelve con una segunda consulta y se combina en Dart.
  Future<List<Map<String, dynamic>>> getMyGrades() async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return [];

      final userId = session.user.id;

      final recipesResponse = await _supabase.supabase
          .from('recipes')
          .select('''
            id,
            name,
            type,
            created_at,
            assignment_id,
            assignments!inner (
              id,
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

      final recipes = List<Map<String, dynamic>>.from(recipesResponse);
      if (recipes.isEmpty) return [];

      final assignmentIds =
          recipes.map((r) => r['assignment_id']).toSet().toList();

      final gradesResponse = await _supabase.supabase
          .from('grades')
          .select('assignment_id, stars')
          .eq('student_id', userId)
          .inFilter('assignment_id', assignmentIds);

      final gradesMap = {
        for (final g in List<Map<String, dynamic>>.from(gradesResponse))
          g['assignment_id']: g['stars']
      };

      return recipes
          .map((r) => {
                ...r,
                'stars': gradesMap[r['assignment_id']],
              })
          .toList();
    } catch (e) {
      print('Error al obtener calificaciones: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getGradeDetail(String recipeId) async {
    try {
      final recipe = await _supabase.supabase
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

      if (recipe == null) return null;

      final grade = await _supabase.supabase
          .from('grades')
          .select('stars')
          .eq('assignment_id', recipe['assignment_id'])
          .eq('student_id', recipe['student_id'])
          .maybeSingle();

      return {
        ...recipe,
        'stars': grade?['stars'],
      };
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
  // FIX: se quitó el embed anidado assignments->recipes->grades(score) que
  // no existe y que además no se estaba usando en ninguna pantalla.
  Future<Map<String, dynamic>?> getClassDetail(String classId) async {
    try {
      final response = await _supabase.supabase
          .from('classes')
          .select()
          .eq('id', classId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener detalle de clase: $e');
      return null;
    }
  }

  // FIX: se quitó el embed grades(score) inválido. Además, antes se
  // regresaban las recetas de TODOS los alumnos de la clase dentro de cada
  // assignment, lo que hacía que "Entregado" apareciera aunque el alumno
  // actual no hubiera subido nada (bastaba con que un compañero sí lo
  // hubiera hecho). Ahora se filtran solo las recetas del alumno en sesión
  // y se agrega su calificación (stars) por separado.
  Future<List<Map<String, dynamic>>> getClassAssignments(
      String classId) async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      final userId = session?.user.id;

      final response = await _supabase.supabase
          .from('assignments')
          .select('''
            *,
            recipes (
              id,
              student_id,
              created_at
            )
          ''')
          .eq('class_id', classId)
          .order('created_at', ascending: false);

      final assignments = List<Map<String, dynamic>>.from(response);
      if (assignments.isEmpty) return [];

      Map<dynamic, dynamic> gradesMap = {};
      if (userId != null) {
        final assignmentIds = assignments.map((a) => a['id']).toList();
        final gradesResponse = await _supabase.supabase
            .from('grades')
            .select('assignment_id, stars')
            .eq('student_id', userId)
            .inFilter('assignment_id', assignmentIds);
        gradesMap = {
          for (final g in List<Map<String, dynamic>>.from(gradesResponse))
            g['assignment_id']: g['stars']
        };
      }

      return assignments.map((a) {
        final allRecipes = List<Map<String, dynamic>>.from(a['recipes'] ?? []);
        final myRecipes = userId == null
            ? <Map<String, dynamic>>[]
            : allRecipes.where((r) => r['student_id'] == userId).toList();

        return {
          ...a,
          'recipes': myRecipes, // solo las del alumno en sesión
          'stars': gradesMap[a['id']],
        };
      }).toList();
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
      final userId = session.user.id;

      final recipe = await _supabase.supabase
          .from('recipes')
          .select()
          .eq('assignment_id', assignmentId)
          .eq('student_id', userId)
          .maybeSingle();

      if (recipe == null) return null;

      final grade = await _supabase.supabase
          .from('grades')
          .select('stars')
          .eq('assignment_id', assignmentId)
          .eq('student_id', userId)
          .maybeSingle();

      return {
        ...recipe,
        'stars': grade?['stars'],
      };
    } catch (e) {
      print('Error al obtener mi entrega: $e');
      return null;
    }
  }

  // ==================== SUBIR RECETARIO COMPLETO ====================
  // NOTA: este método no está siendo llamado por ninguna pantalla en este
  // momento (upload_recipe_screen.dart usa RecipeController.createRecipe,
  // una receta a la vez). Si van a usar "recetario con varias recetas",
  // revisen que 'ingredients' vaya como List/Map real (jsonb), no String,
  // igual que en upload_recipe_screen.dart.
  Future<bool> submitRecipes({
    required String assignmentId,
    required List<Map<String, dynamic>> recipes,
  }) async {
    try {
      final session = _supabase.supabase.auth.currentSession;
      if (session == null) return false;

      await _supabase.supabase
          .from('recipes')
          .delete()
          .eq('assignment_id', assignmentId)
          .eq('student_id', session.user.id);

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