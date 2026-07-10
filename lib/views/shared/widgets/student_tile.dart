import 'package:flutter/material.dart';

class StudentTile extends StatelessWidget {
  final String name;
  final String status;
  final double? grade;
  final VoidCallback onTap;
  final String? avatarUrl;

  const StudentTile({
    super.key,
    required this.name,
    required this.status,
    this.grade,
    required this.onTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStatusColor(status).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl != null 
                    ? NetworkImage(avatarUrl!) 
                    : null,
                child: avatarUrl == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
              ),
              if (grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    grade!.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  Color _getGradeColor(double grade) {
    if (grade >= 9) return Colors.green;
    if (grade >= 7) return Colors.orange;
    return Colors.red;
  }
}