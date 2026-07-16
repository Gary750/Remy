import 'package:flutter/material.dart';
import 'package:remy/controllers/student_controller.dart';

class MyGradesScreen extends StatefulWidget {
  const MyGradesScreen({super.key});

  @override
  State<MyGradesScreen> createState() => _MyGradesScreenState();
}

class _MyGradesScreenState extends State<MyGradesScreen> {
  final StudentController studentController = StudentController();

  bool isLoading = true;
  List<Map<String, dynamic>> gradesByClass = [];

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => isLoading = true);
    try {
      final data = await studentController.getMyGrades();
      if (mounted) setState(() => gradesByClass = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  double? get _overallAverage {
    final allStars = gradesByClass
        .expand((c) => c['grades'] as List)
        .map((g) => g['stars'])
        .where((s) => s != null)
        .cast<int>()
        .toList();
    if (allStars.isEmpty) return null;
    return allStars.reduce((a, b) => a + b) / allStars.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gradesByClass.isEmpty
              ? _buildEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth =
                        constraints.maxWidth > 800 ? 800.0 : constraints.maxWidth;
                    return Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: RefreshIndicator(
                          onRefresh: _loadGrades,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildAverageCard(),
                              const SizedBox(height: 20),
                              ...gradesByClass.map(_buildClassSection),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildAverageCard() {
    final avg = _overallAverage;
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promedio general',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  avg != null
                      ? Row(
                          children: [
                            Text(
                              avg.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text(' / 5', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : const Text('Aún sin calificaciones'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSection(Map<String, dynamic> classData) {
    final List grades = classData['grades'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${classData['subject']} · Grupo ${classData['group_name']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: grades.map<Widget>((g) => _buildGradeRow(g)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeRow(Map<String, dynamic> grade) {
    final int? stars = grade['stars'];

    return ListTile(
      title: Text(grade['assignment_title'] ?? ''),
      subtitle: Text(
        grade['recipe_name'] != null
            ? 'Receta: ${grade['recipe_name']}'
            : 'Aún no entregado',
        style: TextStyle(
          fontSize: 12,
          color: grade['recipe_name'] != null ? Colors.grey[600] : Colors.orange,
        ),
      ),
      trailing: stars != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 18,
                  color: Colors.amber,
                );
              }),
            )
          : Text(
              'Pendiente',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes calificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}