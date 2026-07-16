// lib/controllers/recipe_controller.dart
import '../config/supabase_client.dart';

class RecipeController {
  /// Crea una nueva receta ligada al alumno autenticado.
  Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> data) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final payload = {
        ...data,
        'student_id': user.id,
      };

      final response =
          await supabase.from('recipes').insert(payload).select().single();

      return response;
    } catch (e) {
      throw 'Error al crear la receta: $e';
    }
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> data) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      await supabase
          .from('recipes')
          .update(data)
          .eq('id', recipeId)
          .eq('student_id', user.id);
    } catch (e) {
      throw 'Error al actualizar la receta: $e';
    }
  }

  /// Recetas del alumno autenticado, con su calificación (si existe).
  /// NOTA: 'grades' no tiene FK directa a 'recipes' -- se conecta por
  /// (assignment_id, student_id), así que se hace un segundo query y
  /// se combina en Dart en lugar de usar un embed de PostgREST.
  Future<List<Map<String, dynamic>>> getMyRecipes() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No hay sesión activa';

      final recipesResponse = await supabase
          .from('recipes')
          .select()
          .eq('student_id', user.id)
          .order('created_at', ascending: false);

      final recipes = List<Map<String, dynamic>>.from(recipesResponse);
      if (recipes.isEmpty) return [];

      final assignmentIds =
          recipes.map((r) => r['assignment_id']).toSet().toList();

      final gradesResponse = await supabase
          .from('grades')
          .select('assignment_id, stars')
          .eq('student_id', user.id)
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
      throw 'Error al cargar tus recetas: $e';
    }
  }

  /// Receta específica de un alumno para una entrega dada
  /// (usado por el profesor en student_recipe_screen).
  Future<Map<String, dynamic>?> getRecipeByAssignmentAndStudent(
      String assignmentId, String studentId) async {
    try {
      final recipe = await supabase
          .from('recipes')
          .select()
          .eq('assignment_id', assignmentId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (recipe == null) return null;

      final grade = await supabase
          .from('grades')
          .select('stars')
          .eq('assignment_id', assignmentId)
          .eq('student_id', studentId)
          .maybeSingle();

      return {
        ...recipe,
        'stars': grade?['stars'],
      };
    } catch (e) {
      throw 'Error al cargar la receta: $e';
    }
  }

  /// Detalle completo de una receta por id, con calificación y nombre del autor.
  Future<Map<String, dynamic>> getRecipeDetail(String recipeId) async {
    try {
      final recipe = await supabase
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();

      final grade = await supabase
          .from('grades')
          .select('stars')
          .eq('assignment_id', recipe['assignment_id'])
          .eq('student_id', recipe['student_id'])
          .maybeSingle();

      final profile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', recipe['student_id'])
          .maybeSingle();

      return {
        ...recipe,
        'stars': grade?['stars'],
        'author': profile?['full_name'] ?? 'Alumno',
      };
    } catch (e) {
      throw 'Error al cargar el detalle de la receta: $e';
    }
  }

  /// Búsqueda y filtrado avanzado de recetas (RF-11).
  Future<List<Map<String, dynamic>>> searchRecipes({
    String? query,
    String? type,
    String? country,
    String? cookingStyle,
  }) async {
    try {
      var builder = supabase.from('recipes').select();

      if (query != null && query.trim().isNotEmpty) {
        builder = builder.ilike('name', '%${query.trim()}%');
      }
      if (type != null) {
        builder = builder.eq('type', type);
      }
      if (country != null) {
        builder = builder.eq('country', country);
      }
      if (cookingStyle != null) {
        builder = builder.eq('cooking_style', cookingStyle);
      }

      final recipesResponse = await builder.order('created_at', ascending: false);
      final recipes = List<Map<String, dynamic>>.from(recipesResponse);
      if (recipes.isEmpty) return [];

      final studentIds = recipes.map((r) => r['student_id']).toSet().toList();
      final assignmentIds =
          recipes.map((r) => r['assignment_id']).toSet().toList();

      // Nombres de los autores
      final profilesResponse = await supabase
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', studentIds);
      final profilesMap = {
        for (final p in List<Map<String, dynamic>>.from(profilesResponse))
          p['id']: p['full_name']
      };

      // Calificaciones (se unen por la pareja assignment_id + student_id)
      final gradesResponse = await supabase
          .from('grades')
          .select('assignment_id, student_id, stars')
          .inFilter('assignment_id', assignmentIds);
      final gradesMap = {
        for (final g in List<Map<String, dynamic>>.from(gradesResponse))
          '${g['assignment_id']}_${g['student_id']}': g['stars']
      };

      return recipes.map((r) {
        final key = '${r['assignment_id']}_${r['student_id']}';
        return {
          ...r,
          'stars': gradesMap[key],
          'author': profilesMap[r['student_id']] ?? 'Alumno',
        };
      }).toList();
    } catch (e) {
      throw 'Error al buscar recetas: $e';
    }
  }

  /// Lista de países distintos ya usados en recetas, para poblar el filtro.
  Future<List<String>> getAvailableCountries() async {
    try {
      final response = await supabase.from('recipes').select('country');
      final countries = List<Map<String, dynamic>>.from(response)
          .map((r) => r['country'] as String?)
          .where((c) => c != null && c.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      countries.sort();
      return countries;
    } catch (e) {
      throw 'Error al cargar países: $e';
    }
  }
}