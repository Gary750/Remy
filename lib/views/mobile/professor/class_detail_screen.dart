import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/models/assignment_model.dart';
import 'package:remy/providers/assignment_provider.dart';
import 'package:remy/providers/enrollment_provider.dart';
import 'package:remy/services/supabase_service.dart';
import 'package:remy/views/mobile/professor/create_assignment_screen.dart';
import 'package:remy/views/mobile/professor/student_recipe_screen.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';
import 'package:flutter/services.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Todos';
  
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String? _error;
  String? _classCode;
  AssignmentModel? _activeAssignment;

  final SupabaseService _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  String _toSafeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    try {
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> _extractProfile(dynamic profileData) {
    if (profileData == null) return {};
    if (profileData is Map<String, dynamic>) return profileData;
    if (profileData is List && profileData.isNotEmpty) {
      final first = profileData.first;
      if (first is Map<String, dynamic>) return first;
    }
    return {};
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);
      await enrollmentProvider.loadStudents(widget.classId);
      
      if (!mounted) return;
      final assignmentProvider = Provider.of<AssignmentProvider>(context, listen: false);
      await assignmentProvider.loadAssignments(widget.classId);
      _activeAssignment = assignmentProvider.activeAssignment;

      final classData = await _supabase.supabase
          .from('classes')
          .select('join_code')
          .eq('id', widget.classId)
          .maybeSingle();
      
      if (classData != null) {
        _classCode = classData['join_code'];
      }

      final studentsData = enrollmentProvider.students;
      final List<Map<String, dynamic>> processed = [];

      for (var student in studentsData) {
        final profile = _extractProfile(student['profiles']);
        final studentId = _toSafeString(student['student_id']);
        
        if (_activeAssignment == null) {
          processed.add({
            'student_id': studentId,
            'full_name': _toSafeString(profile['full_name']),
            'email': _toSafeString(profile['email']),
            'status': 'Sin entrega activa',
            'matricula': await _getStudentMatricula(studentId),
            'calificacion': 0.0,
            'submission_date': null,
            'has_submission': false,
          });
          continue;
        }
        
        final submission = await _getStudentSubmission(studentId);
        final hasSubmission = submission != null;
        final status = hasSubmission ? 'Entregado' : 'Pendiente';
        final grade = hasSubmission ? await _getStudentGrade(studentId) : 0.0;
        final submissionDate = hasSubmission ? submission['created_at'] : null;
        
        processed.add({
          'student_id': studentId,
          'full_name': _toSafeString(profile['full_name']),
          'email': _toSafeString(profile['email']),
          'status': status,
          'matricula': await _getStudentMatricula(studentId),
          'calificacion': grade,
          'submission_date': submissionDate,
          'has_submission': hasSubmission,
        });
      }
      
      setState(() {
        _students = processed;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getStudentSubmission(String studentId) async {
    if (_activeAssignment == null) return null;
    
    try {
      final response = await _supabase.supabase
          .from('recipes')
          .select('id, created_at')
          .eq('assignment_id', _activeAssignment!.id)
          .eq('student_id', studentId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<double> _getStudentGrade(String studentId) async {
    if (_activeAssignment == null) return 0.0;
    
    try {
      final response = await _supabase.supabase
          .from('grades')
          .select('stars')
          .eq('assignment_id', _activeAssignment!.id)
          .eq('student_id', studentId)
          .maybeSingle();
      
      if (response != null && response['stars'] != null) {
        return (response['stars'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<String> _getStudentMatricula(String studentId) async {
    try {
      final response = await _supabase.supabase
          .from('profiles')
          .select('matricula')
          .eq('id', studentId)
          .maybeSingle();
      return response?['matricula']?.toString() ?? 'Sin matrícula';
    } catch (e) {
      return 'Sin matrícula';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month - $hour:$minute';
    } catch (e) {
      return dateStr;
    }
  }

  void _copyClassCode() {
    if (_classCode != null && _classCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _classCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código "$_classCode" copiado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((student) {
      final name = student['full_name'].toLowerCase();
      final email = student['email'].toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch = name.contains(query) || email.contains(query);
      
      final status = student['status'];
      
      bool matchesFilter = true;
      if (_filterStatus == 'Entregados') {
        matchesFilter = status == 'Entregado';
      } else if (_filterStatus == 'Pendientes') {
        matchesFilter = status == 'Pendiente';
      } else if (_filterStatus == 'No entregados') {
        matchesFilter = status == 'No entregado';
      } else if (_filterStatus == 'Sin entrega') {
        matchesFilter = status == 'Sin entrega activa';
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int _countByStatus(String status) {
    return _students.where((student) => student['status'] == status).length;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Entregado':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'No entregado':
        return Colors.red;
      case 'Sin entrega activa':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusMaterialIcon(String status) {
    switch (status) {
      case 'Entregado':
        return Icons.check_circle_outline;
      case 'Pendiente':
        return Icons.access_time;
      case 'No entregado':
        return Icons.highlight_off;
      default:
        return Icons.push_pin_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    final activeAssignment = assignmentProvider.activeAssignment;

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando alumnos...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar los datos',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final totalStudents = _students.length;
    final entregados = _countByStatus('Entregado');
    final pendientes = _countByStatus('Pendiente');
    final noEntregados = _countByStatus('No entregado');
    final sinEntrega = _countByStatus('Sin entrega activa');
    final filteredStudents = _filteredStudents;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_students.length} alumnos',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeAssignment != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.task_alt,
                                  color: Colors.green.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeAssignment.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Vence en: ${activeAssignment.timeRemaining}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Límite: ${_formatDate(activeAssignment.dueDate.toIso8601String())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          if (activeAssignment.instructions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.note_outlined,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      activeAssignment.instructions,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay entregas activas. Crea una nueva entrega para ver el progreso de los alumnos.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.people_outline,
                        value: totalStudents.toString(),
                        label: 'Alumnos inscritos',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.check_circle_outline,
                        value: entregados.toString(),
                        label: 'Entregados',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.pending_outlined,
                        value: pendientes.toString(),
                        label: 'Pendientes',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.cancel_outlined,
                        value: noEntregados.toString(),
                        label: 'No entregados',
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar alumno...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterChip('Todos', totalStudents),
                            _buildFilterChip('Entregados', entregados),
                            _buildFilterChip('Pendientes', pendientes),
                            _buildFilterChip('No entregados', noEntregados),
                            if (activeAssignment == null)
                              _buildFilterChip('Sin entrega', sinEntrega),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (filteredStudents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _students.isEmpty
                                  ? 'No hay alumnos inscritos'
                                  : 'No hay alumnos que coincidan',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double tableWidth =
                              constraints.maxWidth < 600 ? 600 : constraints.maxWidth;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: tableWidth,
                              child: Column(
                                children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: _buildHeaderText('ALUMNO')),
                                Expanded(flex: 2, child: _buildHeaderText('MATRÍCULA')),
                                Expanded(flex: 1, child: _buildHeaderText('ESTADO')),
                                Expanded(flex: 1, child: _buildHeaderText('FECHA')),
                                Expanded(flex: 2, child: _buildHeaderText('CALIFICACIÓN')),
                              ],
                            ),
                          ),
                          
                          ...filteredStudents.map((student) {
                            final status = student['status'];
                            final matricula = student['matricula'];
                            final calificacion = student['calificacion'] as double;
                            final statusColor = _getStatusColor(status);
                            final statusIcon = _getStatusMaterialIcon(status);
                            final hasGrade = calificacion > 0;
                            final submissionDate = student['submission_date'];
                            final hasSubmission = student['has_submission'] ?? false;

                            return InkWell(
                              onTap: () {
                                if (hasSubmission && activeAssignment != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentRecipeScreen(
                                        classId: widget.classId,
                                        studentId: student['student_id'],
                                        studentName: student['full_name'],
                                        assignmentId: activeAssignment.id,
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                } else if (activeAssignment == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No hay entrega activa'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Este alumno aún no ha entregado su recetario'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.orange.shade100,
                                            child: Text(
                                              _toSafeString(student['full_name']).isNotEmpty
                                                  ? _toSafeString(student['full_name'])[0].toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFE65100),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _toSafeString(student['full_name']),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        matricula,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: statusColor.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                             Icon(
                                               statusIcon,
                                               size: 11,
                                               color: statusColor,
                                             ),
                                            const SizedBox(width: 2),
                                            Flexible(
                                              child: Text(
                                                status == 'Sin entrega activa' ? 'Sin entrega' : status,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: statusColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    Expanded(
                                       flex: 1,
                                       child: Text(
                                         submissionDate != null ? _formatDate(submissionDate) : '—',
                                         style: TextStyle(
                                           fontSize: 11,
                                           color: submissionDate != null 
                                               ? Colors.grey.shade700 
                                               : Colors.grey.shade400,
                                         ),
                                       ),
                                     ),
                                     
                                     Expanded(
                                       flex: 2,
                                       child: hasGrade
                                           ? FittedBox(
                                               fit: BoxFit.scaleDown,
                                               alignment: Alignment.centerLeft,
                                               child: Row(
                                                 children: List.generate(5, (starIndex) {
                                                   final isFull = starIndex < calificacion.floor();
                                                   final isHalf = !isFull && starIndex < calificacion.ceil() && calificacion % 1 != 0;
                                                   
                                                   return Padding(
                                                     padding: const EdgeInsets.only(right: 2),
                                                     child: Icon(
                                                       isFull 
                                                           ? Icons.star 
                                                           : isHalf 
                                                               ? Icons.star_half 
                                                               : Icons.star_border,
                                                       size: 16,
                                                       color: isFull || isHalf 
                                                           ? Colors.amber 
                                                           : Colors.grey.shade300,
                                                     ),
                                                   );
                                                 }),
                                               ),
                                             )
                                           : Text(
                                               status == 'Entregado' 
                                                   ? 'Sin calificar' 
                                                   : '—',
                                               style: TextStyle(
                                                 fontSize: 12,
                                                 color: status == 'Entregado' 
                                                     ? Colors.grey.shade500 
                                                     : Colors.grey.shade400,
                                                 fontStyle: status == 'Entregado' 
                                                     ? FontStyle.italic 
                                                     : FontStyle.normal,
                                               ),
                                             ),
                                     ),
                                   ],
                                 ),
                               ),
                             );
                           }).toList(),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mostrando ${filteredStudents.length} de $totalStudents alumnos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  if (_classCode != null && _classCode!.isNotEmpty)
                                    GestureDetector(
                                      onTap: _copyClassCode,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE65100),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.copy,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Copiar código',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_classCode != null && _classCode!.isNotEmpty)
            FloatingActionButton(
              heroTag: 'copiar_codigo',
              onPressed: _copyClassCode,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFE65100),
              elevation: 2,
              child: const Icon(Icons.copy, color: Color(0xFFE65100)),
            ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'nueva_entrega',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAssignmentScreen(
                    classId: widget.classId,
                  ),
                ),
              ).then((_) => _loadData());
            },
            backgroundColor: const Color(0xFFE65100),
            icon: const Icon(Icons.add, color: Colors.white, size: 22),
            label: const Text(
              'Nueva entrega',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _filterStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE65100) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE65100) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.3,
      ),
    );
  }
}