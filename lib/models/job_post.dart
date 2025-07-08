class JobPost {
  final String id;
  final String title;
  final String jobType;
  final String category;
  final String district;
  final String description;
  final String contactPhone;
  final String postedBy; // User ID
  final DateTime createdAt;
  final bool isActive;

  JobPost({
    required this.id,
    required this.title,
    required this.jobType,
    required this.category,
    required this.district,
    required this.description,
    required this.contactPhone,
    required this.postedBy,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory JobPost.fromMap(Map<String, dynamic> map, String id) {
    return JobPost(
      id: id,
      title: map['title'] ?? '',
      jobType: map['jobType'] ?? '',
      category: map['category'] ?? '',
      district: map['district'] ?? '',
      description: map['description'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      postedBy: map['postedBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'jobType': jobType,
      'category': category,
      'district': district,
      'description': description,
      'contactPhone': contactPhone,
      'postedBy': postedBy,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  JobPost copyWith({
    String? id,
    String? title,
    String? jobType,
    String? category,
    String? district,
    String? description,
    String? contactPhone,
    String? postedBy,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return JobPost(
      id: id ?? this.id,
      title: title ?? this.title,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
      district: district ?? this.district,
      description: description ?? this.description,
      contactPhone: contactPhone ?? this.contactPhone,
      postedBy: postedBy ?? this.postedBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
