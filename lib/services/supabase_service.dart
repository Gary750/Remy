import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math'; // ✅ IMPORTAR PARA Random

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  late final SupabaseClient client;

  SupabaseService._internal();

  Future<void> init() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Faltan las variables de entorno de Supabase');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    client = Supabase.instance.client;
    print('✅ Supabase conectado correctamente');
  }

  SupabaseClient get supabase => client;

  // ==================== AUTH ====================
  Future<AuthResponse> signIn(String email, String password) async {
    print('🔐 signIn - Intentando autenticar: $email');
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    print('🔐 signIn - Respuesta: ${response.user != null ? "Éxito" : "Falló"}');
    return response;
  }

  Future<AuthResponse> signUp(String email, String password, String fullName, String role) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await client.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ==================== PROFILES ====================
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      print('📥 getProfile - Buscando perfil para userId: $userId');
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      print('📥 getProfile - Resultado: ${response != null ? "Encontrado" : "No encontrado"}');
      return response;
    } catch (e) {
      print('❌ Error al obtener perfil: $e');
      return null;
    }
  }

  // ==================== CLASSES ====================
  Future<List<Map<String, dynamic>>> getProfessorClasses(String professorId) async {
    try {
      final response = await client
          .from('classes')
          .select('*')
          .eq('professor_id', professorId)
          .order('created_at', ascending: false);
      
      final List<Map<String, dynamic>> classes = [];
      for (var cls in response) {
        final count = await getStudentCountByClass(cls['id']);
        classes.add({
          ...cls,
          'student_count': count,
        });
      }
      
      print('📊 Clases cargadas: ${classes.length}');
      for (var cls in classes) {
        print('📚 ${cls['subject']} - Alumnos: ${cls['student_count']}');
      }
      
      return classes;
    } catch (e) {
      print('❌ Error al obtener clases: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createClass({
    required String professorId,
    required String subject,
    required String term,
    required String groupName,
  }) async {
    final code = _generateJoinCode(subject, term, groupName);

    final data = {
      'professor_id': professorId,
      'subject': subject,
      'term': term,
      'group_name': groupName,
      'join_code': code,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await client
        .from('classes')
        .insert(data)
        .select()
        .single();

    return response;
  }

  // ==================== ✅ GENERAR CÓDIGO CON ALEATORIOS REALES ====================
  String _generateJoinCode(String subject, String term, String groupName) {
    // Extraer primeras letras de la materia (3 letras máximo)
    String subjectCode = '';
    final words = subject.split(' ');
    if (words.length >= 2) {
      subjectCode = words.map((w) => w[0]).join('').toUpperCase();
    } else {
      subjectCode = subject.substring(0, subject.length > 3 ? 3 : subject.length).toUpperCase();
    }
    
    if (subjectCode.length > 3) subjectCode = subjectCode.substring(0, 3);
    if (subjectCode.length < 2) subjectCode = subjectCode.padRight(2, 'X');

    // Número del cuatrimestre
    final termNum = RegExp(r'(\d+)').firstMatch(term)?.group(1) ?? '0';

    // ✅ USAR Random() PARA GENERAR 4 CARACTERES ALEATORIOS
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    String randomCode = '';
    for (var i = 0; i < 4; i++) {
      final randomIndex = random.nextInt(chars.length);
      randomCode += chars[randomIndex];
    }

    return '$subjectCode-$termNum$groupName-$randomCode';
  }

  // ==================== ASSIGNMENTS ====================
  Future<List<Map<String, dynamic>>> getClassAssignments(String classId) async {
    try {
      final response = await client
          .from('assignments')
          .select()
          .eq('class_id', classId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createAssignment({
    required String classId,
    required String title,
    required String recipeType,
    required DateTime dueDate,
    String? instructions,
  }) async {
    final data = {
      'class_id': classId,
      'title': title,
      'type': 'recetario',
      'recipe_type': recipeType,
      'due_date': dueDate.toIso8601String(),
      'instructions': instructions ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await client
        .from('assignments')
        .insert(data)
        .select()
        .single();

    return response;
  }

  // ==================== ENROLLMENTS ====================
  Future<List<Map<String, dynamic>>> getStudentsByClass(String classId) async {
    try {
      final response = await client
          .from('enrollments')
          .select('''
            id,
            student_id,
            joined_at,
            profiles!inner (
              id,
              full_name,
              email,
              avatar_url
            )
          ''')
          .eq('class_id', classId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ==================== CONTAR ALUMNOS POR CLASE ====================
  Future<int> getStudentCountByClass(String classId) async {
    try {
      final response = await client
          .from('enrollments')
          .select('id')
          .eq('class_id', classId);
      
      final count = response.length;
      print('📊 Clase $classId tiene $count alumnos');
      return count;
    } catch (e) {
      print('❌ Error al contar alumnos: $e');
      return 0;
    }
  }
}