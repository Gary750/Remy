class AppRoutes {
  // ==================== RUTAS DE AUTENTICACIÓN ====================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ==================== RUTAS DEL PROFESOR ====================
  static const String professorDashboard = '/professor-dashboard';
  static const String professorCreateClass = '/professor-create-class';
  static const String professorClassDetail = '/professor-class-detail';
  static const String professorCreateAssignment = '/professor-create-assignment';
  static const String professorStudentRecipe = '/professor-student-recipe';
  static const String professorProfile = '/professor-profile';

  // ==================== RUTAS DEL ALUMNO ====================
  static const String studentDashboard = '/student-dashboard';
  static const String studentJoinClass = '/student-join-class';
  static const String studentClassDetail = '/student-class-detail';
  static const String studentUploadRecipe = '/student-upload-recipe';
  static const String studentMyRecipes = '/student-my-recipes';
  static const String studentSearchRecipes = '/student-search-recipes';
  static const String studentMyGrades = '/student-my-grades';
  static const String studentProfile = '/student-profile';

  // ==================== RUTAS COMPARTIDAS (ALIAS) ====================
  static const String dashboard = '/dashboard';
  static const String createClass = '/create-class';
  static const String classDetail = '/class-detail';
  static const String createAssignment = '/create-assignment';
  static const String studentRecipe = '/student-recipe';
  static const String profile = '/profile';
  
  // ==================== ALIAS PARA USO COMÚN ====================
  static const String myRecipes = '/student-my-recipes';
  static const String uploadRecipe = '/student-upload-recipe';
  static const String myGrades = '/student-my-grades';
  static const String searchRecipes = '/student-search-recipes';

  // ==================== MÉTODO PARA OBTENER RUTA CON PARÁMETROS ====================
  static String classDetailWithId(String classId, {bool isProfessor = true}) {
    return isProfessor 
        ? '$professorClassDetail?classId=$classId'
        : '$studentClassDetail?classId=$classId';
  }

  static String studentRecipeWithId(String studentId, String assignmentId) {
    return '$studentRecipe?studentId=$studentId&assignmentId=$assignmentId';
  }
}