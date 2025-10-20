import 'package:codemy_app/src/core/models/entity.dart';

class User extends EntityModel {
  final String name;
  final String email;
  final String googleId;
  final int role;
  final int status;
  final String profilePicture;
  final String? bio;
  final bool emailVerified;
  final int totalCourses;
  final double? rating;

  const User({
    required this.name,
    required this.email,
    required this.googleId,
    required this.role,
    required this.status,
    required this.profilePicture,
    this.bio,
    required this.emailVerified,
    required this.totalCourses,
    this.rating,
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
    super.isDeleted = false,
    super.deletedAt,
    super.deletedBy,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      googleId: json['googleId'] as String,
      role: json['role'] as int,
      status: json['status'] as int,
      profilePicture: json['profilePicture'] as String,
      bio: json['bio'] as String?,
      emailVerified: json['emailVerified'] as bool,
      totalCourses: json['totalCourses'] as int,
      rating: json['rating'] as double?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      updatedBy: json['updatedBy'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      deletedBy: json['deletedBy'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'googleId': googleId,
      'role': role,
      'status': status,
      'profilePicture': profilePicture,
      'bio': bio,
      'emailVerified': emailVerified,
      'totalCourses': totalCourses,
      'rating': rating,
      'createdAt': createdAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
    };
  }
}
