import 'package:flutter/material.dart';
import 'package:remy/models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;
  final bool showStudentCount;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.onTap,
    this.showStudentCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final studentCount = classModel.studentCount ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== MATERIA ==========
              Text(
                classModel.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),

              // ========== GRUPO ==========
              Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Grupo: ${classModel.groupName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ========== CÓDIGO ==========
              Row(
                children: [
                  Icon(
                    Icons.code_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Código: ${classModel.joinCode}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ========== ALUMNOS ==========
              if (showStudentCount)
                Row(
                  children: [
                    Icon(
                      studentCount > 0 ? Icons.people_alt : Icons.people_outline,
                      size: 16,
                      color: studentCount > 0 ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      studentCount > 0
                          ? '$studentCount ${studentCount == 1 ? 'alumno' : 'alumnos'}'
                          : 'Sin alumnos inscritos',
                      style: TextStyle(
                        fontSize: 13,
                        color: studentCount > 0 ? Colors.grey.shade600 : Colors.grey.shade400,
                        fontStyle: studentCount == 0 ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}