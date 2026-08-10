// ─────────────────────────────────────────────────────────────────────────────
// lib/models/course_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

enum CourseLevel { beginner, intermediate, advanced }

extension CourseLevelExt on CourseLevel {
  String get value {
    switch (this) {
      case CourseLevel.beginner: return 'beginner';
      case CourseLevel.intermediate: return 'intermediate';
      case CourseLevel.advanced: return 'advanced';
    }
  }

  String get label {
    switch (this) {
      case CourseLevel.beginner: return 'Beginner';
      case CourseLevel.intermediate: return 'Intermediate';
      case CourseLevel.advanced: return 'Advanced';
    }
  }

  static CourseLevel fromString(String? s) {
    switch (s) {
      case 'intermediate': return CourseLevel.intermediate;
      case 'advanced': return CourseLevel.advanced;
      default: return CourseLevel.beginner;
    }
  }
}

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String? thumbnailUrl;
  final List<String> facultyIds;
  final String? duration;    // e.g., "4 weeks", "20 hours"
  final CourseLevel level;
  final String status;       // draft | published | archived
  final int moduleCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    this.categoryName,
    this.thumbnailUrl,
    this.facultyIds = const [],
    this.duration,
    this.level = CourseLevel.beginner,
    this.status = 'published',
    this.moduleCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      thumbnailUrl: data['thumbnailUrl'],
      facultyIds: List<String>.from(data['facultyIds'] ?? []),
      duration: data['duration'],
      level: CourseLevelExt.fromString(data['level']),
      status: data['status'] ?? 'published',
      moduleCount: data['moduleCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'thumbnailUrl': thumbnailUrl,
      'facultyIds': facultyIds,
      'duration': duration,
      'level': level.value,
      'status': status,
      'moduleCount': moduleCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isPublished => status == 'published';
}
