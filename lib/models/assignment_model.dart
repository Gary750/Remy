class AssignmentModel {
  final String id;
  final String classId;
  final String title;
  final String type;
  final String recipeType; // 'Comida', 'Bebida' o 'Ambos'
  final DateTime dueDate;
  final String instructions;
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.type,
    required this.recipeType,
    required this.dueDate,
    required this.instructions,
    required this.createdAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] ?? '',
      classId: json['class_id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'recetario',
      recipeType: json['recipe_type'] ?? 'Ambos',
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      instructions: json['instructions'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'title': title,
      'type': type,
      'recipe_type': recipeType,
      'due_date': dueDate.toIso8601String(),
      'instructions': instructions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive {
    try {
      return dueDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  String get timeRemaining {
    try {
      if (dueDate.isBefore(DateTime.now())) return 'Cerrada';
      final diff = dueDate.difference(DateTime.now());
      if (diff.inDays > 0) {
        return '${diff.inDays}d ${diff.inHours % 24}h';
      }
      if (diff.inHours > 0) {
        return '${diff.inHours}h ${diff.inMinutes % 60}m';
      }
      return '${diff.inMinutes}m';
    } catch (e) {
      return '--';
    }
  }
}