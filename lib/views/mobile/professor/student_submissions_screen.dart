import 'package:flutter/material.dart';
import 'package:remy/models/assignment_model.dart';
import 'package:remy/services/supabase_service.dart';
import 'package:remy/views/mobile/professor/student_recipe_screen.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';

class StudentSubmissionsScreen extends StatefulWidget {
  final String classId;
  final String studentId;
  final String studentName;
  final String matricula;

  const StudentSubmissionsScreen({
    super.key,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.matricula,
  });

  @override
  State<StudentSubmissionsScreen> createState() =>
      _StudentSubmissionsScreenState();
}

class _StudentSubmissionsScreenState
    extends State<StudentSubmissionsScreen> {
  final SupabaseService _supabase = SupabaseService();

  bool _isLoading = true;
  String? _error;

  // Lista de entregas con su submission/calificación para este alumno
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Todas las entregas (assignments) de la clase
      final assignmentsRaw = await _supabase.supabase
          .from('assignments')
          .select()
          .eq('class_id', widget.classId)
          .order('created_at', ascending: false);

      final assignments = (assignmentsRaw as List)
          .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // 2. Para cada entrega, buscar submission + calificación del alumno
      final List<Map<String, dynamic>> rows = [];

      for (final assignment in assignments) {
        // Submission
        final submissionRaw = await _supabase.supabase
            .from('recipes')
            .select('id, created_at, name')
            .eq('assignment_id', assignment.id)
            .eq('student_id', widget.studentId)
            .maybeSingle();

        final hasSubmission = submissionRaw != null;

        // Calificación
        double grade = 0.0;
        if (hasSubmission) {
          final gradeRaw = await _supabase.supabase
              .from('grades')
              .select('stars')
              .eq('assignment_id', assignment.id)
              .eq('student_id', widget.studentId)
              .maybeSingle();
          if (gradeRaw != null && gradeRaw['stars'] != null) {
            grade = (gradeRaw['stars'] as num).toDouble();
          }
        }

        // Permiso de entrega tardía
        bool lateAllowed = false;
        if (!hasSubmission && !assignment.isActive) {
          final lateRaw = await _supabase.supabase
              .from('late_submissions')
              .select('id')
              .eq('student_id', widget.studentId)
              .eq('assignment_id', assignment.id)
              .maybeSingle();
          lateAllowed = lateRaw != null;
        }

        String status;
        if (hasSubmission) {
          status = 'Entregado';
        } else if (assignment.isActive) {
          status = 'Pendiente';
        } else {
          status = 'No entregado';
        }

        rows.add({
          'assignment': assignment,
          'has_submission': hasSubmission,
          'submission_date': hasSubmission ? submissionRaw['created_at'] : null,
          'recipe_name': hasSubmission ? (submissionRaw['name'] ?? '') : '',
          'grade': grade,
          'status': status,
          'late_allowed': lateAllowed,
        });
      }

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _allowLateSubmission(String assignmentId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permitir entrega / Prórroga'),
        content: Text(
          '¿Deseas permitir que ${widget.studentName} pueda subir la receta de "$title" aunque el plazo ya venció?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
            ),
            child: const Text('Sí, permitir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _supabase.supabase.from('late_submissions').upsert({
        'student_id': widget.studentId,
        'assignment_id': assignmentId,
        'allowed_at': DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se otorgó prórroga a ${widget.studentName}.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al otorgar prórroga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year  $hour:$minute';
    } catch (_) {
      return dateStr;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Entregado':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'No entregado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Entregado':
        return Icons.check_circle_outline;
      case 'Pendiente':
        return Icons.access_time_outlined;
      case 'No entregado':
        return Icons.highlight_off;
      default:
        return Icons.remove;
    }
  }

  // Resumen: cuántas entregas ha hecho / total, promedio de calificación
  int get _submitted =>
      _rows.where((r) => r['has_submission'] == true).length;
  double get _avgGrade {
    final graded =
        _rows.where((r) => (r['grade'] as double) > 0).toList();
    if (graded.isEmpty) return 0;
    final sum =
        graded.fold<double>(0, (acc, r) => acc + (r['grade'] as double));
    return sum / graded.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              'Matrícula: ${widget.matricula}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando historial...')
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  color: const Color(0xFFE65100),
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Resumen ──
                        _buildSummaryCards(),
                        const SizedBox(height: 24),

                        // ── Título sección ──
                        Row(
                          children: [
                            const Icon(Icons.history,
                                size: 18, color: Color(0xFFE65100)),
                            const SizedBox(width: 8),
                            const Text(
                              'Historial de entregas',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A)),
                            ),
                            const Spacer(),
                            Text(
                              '${_rows.length} ${_rows.length == 1 ? 'entrega' : 'entregas'}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Lista de entregas ──
                        if (_rows.isEmpty)
                          _buildEmpty()
                        else
                          ..._rows.asMap().entries.map((entry) {
                            final i = entry.key;
                            final row = entry.value;
                            return _buildSubmissionCard(row, i + 1);
                          }),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    final avg = _avgGrade;
    return Row(
      children: [
        _summaryCard(
          icon: Icons.assignment_outlined,
          value: '$_submitted/${_rows.length}',
          label: 'Entregas realizadas',
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          icon: Icons.star_outline,
          value: avg > 0 ? avg.toStringAsFixed(1) : '—',
          label: 'Promedio ★',
          color: Colors.amber.shade700,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          icon: Icons.pending_outlined,
          value: _rows
              .where((r) => r['status'] == 'Pendiente')
              .length
              .toString(),
          label: 'Pendientes',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> row, int index) {
    final assignment = row['assignment'] as AssignmentModel;
    final status = row['status'] as String;
    final hasSubmission = row['has_submission'] == true;
    final grade = row['grade'] as double;
    final hasGrade = grade > 0;
    final submissionDate = row['submission_date'] as String?;
    final recipeName = row['recipe_name'] as String;
    final lateAllowed = row['late_allowed'] == true;

    final color = _statusColor(status);
    final icon = _statusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: hasSubmission
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentRecipeScreen(
                      classId: widget.classId,
                      studentId: widget.studentId,
                      studentName: widget.studentName,
                      assignmentId: assignment.id,
                    ),
                  ),
                ).then((_) => _loadData());
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: número + título + badge estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Número de práctica
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'P$index',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.category_outlined,
                                size: 11, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(assignment.recipeType,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500)),
                            const SizedBox(width: 10),
                            Icon(
                              assignment.isActive
                                  ? Icons.radio_button_checked
                                  : Icons.lock_outline,
                              size: 11,
                              color: assignment.isActive
                                  ? Colors.green
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              assignment.isActive
                                  ? 'Activa'
                                  : 'Cerrada',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: assignment.isActive
                                      ? Colors.green
                                      : Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 11, color: color),
                        const SizedBox(width: 4),
                        Text(status,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ],
                    ),
                  ),
                ],
              ),

              // Divider
              if (hasSubmission) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 12),

                // Detalles de la entrega
                Row(
                  children: [
                    // Receta entregada
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receta entregada',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            recipeName.isNotEmpty ? recipeName : '(sin nombre)',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Fecha de entrega
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Entregado',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(submissionDate),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Calificación + botón calificar
                Row(
                  children: [
                    if (hasGrade) ...[
                      // Estrellas
                      Row(
                        children: List.generate(5, (i) {
                          final isFull = i < grade.floor();
                          final isHalf = !isFull &&
                              i < grade.ceil() &&
                              grade % 1 != 0;
                          return Icon(
                            isFull
                                ? Icons.star
                                : isHalf
                                    ? Icons.star_half
                                    : Icons.star_border,
                            size: 18,
                            color: isFull || isHalf
                                ? Colors.amber
                                : Colors.grey.shade300,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${grade.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber),
                      ),
                    ] else
                      Text(
                        'Sin calificar',
                        style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade500),
                      ),
                    const Spacer(),
                    // Botón ver/calificar
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentRecipeScreen(
                              classId: widget.classId,
                              studentId: widget.studentId,
                              studentName: widget.studentName,
                              assignmentId: assignment.id,
                            ),
                          ),
                        ).then((_) => _loadData());
                      },
                      icon: Icon(
                        hasGrade ? Icons.visibility_outlined : Icons.star_outline,
                        size: 14,
                      ),
                      label: Text(
                        hasGrade ? 'Ver receta' : 'Calificar',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE65100),
                        side: const BorderSide(color: Color(0xFFE65100)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ] else if (!assignment.isActive) ...[
                // Entrega cerrada y no entregó
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: lateAllowed ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: lateAllowed ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        lateAllowed ? Icons.check_circle_outline : Icons.info_outline,
                        size: 14,
                        color: lateAllowed ? Colors.green.shade600 : Colors.red.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lateAllowed ? 'Prórroga otorgada (entrega tardía permitida)' : 'No entregó antes del cierre',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: lateAllowed ? Colors.green.shade700 : Colors.red.shade600,
                        ),
                      ),
                      if (!lateAllowed) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _allowLateSubmission(assignment.id, assignment.title),
                          icon: const Icon(Icons.lock_open, size: 13, color: Colors.white),
                          label: const Text('Otorgar prórroga', style: TextStyle(fontSize: 11, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 26),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                // Entrega activa, aún no entrega
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top_outlined,
                          size: 13, color: Colors.orange.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Vence en: ${assignment.timeRemaining}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No hay entregas creadas en esta clase',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error al cargar el historial',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(_error!,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100)),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
