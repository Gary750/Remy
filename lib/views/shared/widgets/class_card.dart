import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String className;
  final int studentsCount;
  final int deliveredCount;
  final String? classCode;
  final VoidCallback onTap;
  final bool isStudent;

  const ClassCard({
    super.key,
    required this.className,
    required this.studentsCount,
    required this.deliveredCount,
    this.classCode,
    required this.onTap,
    this.isStudent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      className,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!isStudent) ...[
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$deliveredCount / $studentsCount alumnos',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (classCode != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.code, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Código: $classCode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: studentsCount > 0 ? deliveredCount / studentsCount : 0,
                  backgroundColor: Colors.grey[200],
                  color: deliveredCount == studentsCount 
                      ? Colors.green 
                      : Colors.orange,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              if (isStudent) ...[
                Row(
                  children: [
                    Icon(Icons.event, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Entrega próxima',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}