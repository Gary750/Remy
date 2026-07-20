import 'package:flutter/material.dart';
import 'package:remy/models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final studentCount = classModel.studentCount ?? 0;
    final termDisplay = classModel.term;

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
              // Cuatrimestre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  termDisplay,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Materia
              Text(
                classModel.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Grupo
              Text(
                'Grupo: ${classModel.groupName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              // Código
              Text(
                'Código: ${classModel.joinCode}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),

              // Alumnos (conteo REAL desde la base de datos)
              Row(
                children: [
                  Icon(
                    studentCount > 0 ? Icons.people_alt : Icons.people_outline,
                    size: 18,
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