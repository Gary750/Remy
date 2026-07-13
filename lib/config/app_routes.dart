class AppRoutes {
  // Rutas de Autenticación
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Rutas del Profesor
  static const String dashboard = '/dashboard';
  static const String createClass = '/create-class';
  static const String classDetail = '/class-detail';
  static const String createAssignment = '/create-assignment';
  static const String studentRecipe = '/student-recipe';
  static const String profile = '/profile';

  // Rutas del Alumno
  static const String studentDashboard = '/student-dashboard'; // my_classes_screen
  static const String studentClassDetail = '/student-class-detail';
  static const String myRecipes = '/my-recipes';
  static const String searchRecipes = '/search-recipes';
  static const String uploadRecipe = '/upload-recipe';
  static const String myGrades = '/my-grades';
}