class UserModel {
  final int id;
  final String cedula;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.cedula,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  /// Instantiates a [UserModel] safely mapping nulls and missing keys from the JSON payload.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      cedula: json['cedula'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? 'Usuario',
      lastName: json['last_name'] ?? 'Desconocido',
      phone: json['phone'],
      role: json['role'] ?? 'tourist',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Helper to get the full name dynamically
  String get fullName => '$firstName $lastName';
}