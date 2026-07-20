class ClassModel {
  final String id;
  final String professorId;
  final String subject;
  final String term;
  final String groupName;
  final String joinCode;
  final DateTime createdAt;
  int? studentCount;

  ClassModel({
    required this.id,
    required this.professorId,
    required this.subject,
    required this.term,
    required this.groupName,
    required this.joinCode,
    required this.createdAt,
    this.studentCount,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    int? count;
    if (json['student_count'] != null) {
      count = json['student_count'] as int?;
    } else if (json['enrollments'] != null) {
      if (json['enrollments'] is List) {
        count = (json['enrollments'] as List).length;
      } else if (json['enrollments'] is Map) {
        count = (json['enrollments'] as Map)['count'] as int?;
      }
    }

    return ClassModel(
      id: json['id'] ?? '',
      professorId: json['professor_id'] ?? '',
      subject: json['subject'] ?? '',
      term: json['term'] ?? '',
      groupName: json['group_name'] ?? '',
      joinCode: json['join_code'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      studentCount: count ?? 0,
    );
  }

  String get displayName => '$subject -- Grupo $groupName';
}