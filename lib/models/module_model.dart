// ─────────────────────────────────────────────────────────────────────────────
// lib/models/module_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int order;
  final String? videoUrl;
  final String? pdfUrl;
  final String? pdfTitle;
  final String? textContent;
  final String? externalUrl;
  final String? quizId;
  final bool isPublished;
  final DateTime? createdAt;

  const ModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.order = 0,
    this.videoUrl,
    this.pdfUrl,
    this.pdfTitle,
    this.textContent,
    this.externalUrl,
    this.quizId,
    this.isPublished = true,
    this.createdAt,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
  bool get hasText => textContent != null && textContent!.isNotEmpty;
  bool get hasQuiz => quizId != null && quizId!.isNotEmpty;

  factory ModuleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModuleModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      order: data['order'] ?? 0,
      videoUrl: data['videoUrl'],
      pdfUrl: data['pdfUrl'],
      pdfTitle: data['pdfTitle'],
      textContent: data['textContent'],
      externalUrl: data['externalUrl'],
      quizId: data['quizId'],
      isPublished: data['isPublished'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'order': order,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'pdfTitle': pdfTitle,
      'textContent': textContent,
      'externalUrl': externalUrl,
      'quizId': quizId,
      'isPublished': isPublished,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
