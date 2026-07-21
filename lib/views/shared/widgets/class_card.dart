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
      margin: EdgeInsets.zero, // para que ocupe todo el espacio del grid
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12), // reducido de 16 a 12
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // para que se ajuste al contenido
            children: [
              // Cuatrimestre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  termDisplay,
                  style: TextStyle(
                    fontSize: 12, // reducido de 13
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6), // reducido de 10
              // Materia
              Text(
                classModel.subject,
                style: const TextStyle(
                  fontSize: 16, // reducido de 18
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Grupo
              Text(
                'Grupo: ${classModel.groupName}',
                style: TextStyle(
                  fontSize: 13, // reducido de 14
                  color: Colors.grey.shade700,
                ),
              ),
              // Código
              Text(
                'Código: ${classModel.joinCode}',
                style: TextStyle(
                  fontSize: 12, // reducido de 13
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              // Alumnos (conteo)
              Row(
                children: [
                  Icon(
                    studentCount > 0 ? Icons.people_alt : Icons.people_outline,
                    size: 16, // reducido de 18
                    color: studentCount > 0 ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      studentCount > 0
                          ? '$studentCount ${studentCount == 1 ? 'alumno' : 'alumnos'}'
                          : 'Sin alumnos inscritos',
                      style: TextStyle(
                        fontSize: 12, // reducido de 13
                        color: studentCount > 0 ? Colors.grey.shade600 : Colors.grey.shade400,
                        fontStyle: studentCount == 0 ? FontStyle.italic : FontStyle.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
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