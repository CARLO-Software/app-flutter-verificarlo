class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? image;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        image: json['image'] as String?,
        role: json['role'] as String? ?? 'inspector',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'image': image,
        'role': role,
      };
}
