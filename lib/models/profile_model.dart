class ProfileModel {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? matricula;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.matricula,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      role: json['role'] ?? 'alumno',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      matricula: json['matricula'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'matricula': matricula,
      'created_at': createdAt.toIso8601String(),
    };
  }
}