class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserType userType;
  final String? jobCategory; // Only for workers
  final String? experience; // Only for workers
  final String? province; // Only for workers
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.userType,
    this.jobCategory,
    this.experience,
    this.province,
    required this.createdAt,
  });

  // Convert from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      return UserModel(
        id: id,
        name: map['name']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        userType: UserType.values.firstWhere(
          (type) => type.toString() == map['userType']?.toString(),
          orElse: () => UserType.normal,
        ),
        jobCategory: map['jobCategory']?.toString(),
        experience: map['experience']?.toString(),
        province: map['province']?.toString(),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing UserModel from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'userType': userType.toString(),
      'jobCategory': jobCategory,
      'experience': experience,
      'province': province,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserType? userType,
    String? jobCategory,
    String? experience,
    String? province,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      jobCategory: jobCategory ?? this.jobCategory,
      experience: experience ?? this.experience,
      province: province ?? this.province,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum UserType {
  normal,
  worker,
}
