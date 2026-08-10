// ─────────────────────────────────────────────────────────────────────────────
// lib/models/user_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { trainee, faculty, admin }

extension UserRoleExt on UserRole {
  String get value {
    switch (this) {
      case UserRole.trainee: return 'trainee';
      case UserRole.faculty: return 'faculty';
      case UserRole.admin: return 'admin';
    }
  }

  static UserRole fromString(String? s) {
    switch (s) {
      case 'faculty': return UserRole.faculty;
      case 'admin': return UserRole.admin;
      default: return UserRole.trainee;
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final UserRole role;

  // Trainee-specific
  final String? batch;
  final String? enrolledCourse;
  final String? enrollmentNumber;

  // Faculty-specific
  final String? designation;
  final String? department;
  final String? specialization;
  final List<String> assignedCourseIds;

  // Shared
  final String status; // pending | active | inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = UserRole.trainee,
    this.batch,
    this.enrolledCourse,
    this.enrollmentNumber,
    this.designation,
    this.department,
    this.specialization,
    this.assignedCourseIds = const [],
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      role: UserRoleExt.fromString(data['role']),
      batch: data['batch'],
      enrolledCourse: data['course'],
      enrollmentNumber: data['enrollmentNumber'],
      designation: data['designation'],
      department: data['department'],
      specialization: data['specialization'],
      assignedCourseIds: List<String>.from(data['assignedCourseIds'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role.value,
      'batch': batch,
      'course': enrolledCourse,
      'enrollmentNumber': enrollmentNumber,
      'designation': designation,
      'department': department,
      'specialization': specialization,
      'assignedCourseIds': assignedCourseIds,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    UserRole? role,
    String? batch,
    String? enrolledCourse,
    String? enrollmentNumber,
    String? designation,
    String? department,
    String? specialization,
    List<String>? assignedCourseIds,
    String? status,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      batch: batch ?? this.batch,
      enrolledCourse: enrolledCourse ?? this.enrolledCourse,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      specialization: specialization ?? this.specialization,
      assignedCourseIds: assignedCourseIds ?? this.assignedCourseIds,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isTrainee => role == UserRole.trainee;
  bool get isFaculty => role == UserRole.faculty;
  bool get isAdmin => role == UserRole.admin;
  bool get isActive => status == 'active';
}
