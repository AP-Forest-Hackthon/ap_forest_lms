// ─────────────────────────────────────────────────────────────────────────────
// lib/models/resource_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

enum ResourceFileType { pdf, image, video, link, document }

extension ResourceFileTypeExt on ResourceFileType {
  String get value {
    switch (this) {
      case ResourceFileType.pdf: return 'pdf';
      case ResourceFileType.image: return 'image';
      case ResourceFileType.video: return 'video';
      case ResourceFileType.link: return 'link';
      case ResourceFileType.document: return 'document';
    }
  }

  static ResourceFileType fromString(String? s) {
    switch (s) {
      case 'image': return ResourceFileType.image;
      case 'video': return ResourceFileType.video;
      case 'link': return ResourceFileType.link;
      case 'document': return ResourceFileType.document;
      default: return ResourceFileType.pdf;
    }
  }
}

class ResourceModel {
  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? fileUrl;
  final ResourceFileType fileType;
  final String? thumbnailUrl;
  final String uploadedBy;
  final String? uploaderName;
  final DateTime? uploadedAt;
  final int downloadCount;
  final String visibility; // public | course-only
  final String? courseId;
  final String? moduleId;

  const ResourceModel({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    this.categoryName,
    this.fileUrl,
    this.fileType = ResourceFileType.pdf,
    this.thumbnailUrl,
    required this.uploadedBy,
    this.uploaderName,
    this.uploadedAt,
    this.downloadCount = 0,
    this.visibility = 'public',
    this.courseId,
    this.moduleId,
  });

  bool get isPdf => fileType == ResourceFileType.pdf;
  bool get isVideo => fileType == ResourceFileType.video;

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      fileUrl: data['fileUrl'],
      fileType: ResourceFileTypeExt.fromString(data['fileType']),
      thumbnailUrl: data['thumbnailUrl'],
      uploadedBy: data['uploadedBy'] ?? '',
      uploaderName: data['uploaderName'],
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
      downloadCount: data['downloadCount'] ?? 0,
      visibility: data['visibility'] ?? 'public',
      courseId: data['courseId'],
      moduleId: data['moduleId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'fileUrl': fileUrl,
      'fileType': fileType.value,
      'thumbnailUrl': thumbnailUrl,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploadedAt': uploadedAt != null
          ? Timestamp.fromDate(uploadedAt!)
          : FieldValue.serverTimestamp(),
      'downloadCount': downloadCount,
      'visibility': visibility,
      'courseId': courseId,
      'moduleId': moduleId,
    };
  }
}
