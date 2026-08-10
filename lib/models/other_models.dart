// ─────────────────────────────────────────────────────────────────────────────
// lib/models/announcement_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String? authorName;
  final String audience; // all | trainee | faculty
  final String? courseId;
  final String priority; // normal | important | urgent
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    this.authorName,
    this.audience = 'all',
    this.courseId,
    this.priority = 'normal',
    this.createdAt,
    this.expiresAt,
  });

  bool get isUrgent => priority == 'urgent';
  bool get isImportant => priority == 'important';

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'],
      audience: data['audience'] ?? 'all',
      courseId: data['courseId'],
      priority: data['priority'] ?? 'normal',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'audience': audience,
      'courseId': courseId,
      'priority': priority,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/models/category_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final int colorIndex;
  final int order;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.colorIndex = 0,
    this.order = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      iconName: data['iconName'],
      colorIndex: data['colorIndex'] ?? 0,
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorIndex': colorIndex,
      'order': order,
      'isActive': isActive,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/models/timetable_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class TimetableModel {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String title;
  final String type; // Lecture | Field Training | Workshop | etc.
  final String? location;
  final String? facultyId;
  final String? facultyName;
  final String? courseId;
  final String? courseName;
  final String? description;
  final String audience; // all | specific batch

  const TimetableModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.type = 'Lecture',
    this.location,
    this.facultyId,
    this.facultyName,
    this.courseId,
    this.courseName,
    this.description,
    this.audience = 'all',
  });

  factory TimetableModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimetableModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      title: data['title'] ?? '',
      type: data['type'] ?? 'Lecture',
      location: data['location'],
      facultyId: data['facultyId'],
      facultyName: data['facultyName'],
      courseId: data['courseId'],
      courseName: data['courseName'],
      description: data['description'],
      audience: data['audience'] ?? 'all',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'type': type,
      'location': location,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'courseId': courseId,
      'courseName': courseName,
      'description': description,
      'audience': audience,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/models/ai_job_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class AiJobModel {
  final String id;
  final String facultyId;
  final String pdfStorageUrl;
  final String pdfFileName;
  final String? courseId;
  final String? moduleId;
  final String status; // queued | processing | completed | failed
  final String? quizId; // populated after completion
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const AiJobModel({
    required this.id,
    required this.facultyId,
    required this.pdfStorageUrl,
    required this.pdfFileName,
    this.courseId,
    this.moduleId,
    this.status = 'queued',
    this.quizId,
    this.errorMessage,
    this.createdAt,
    this.completedAt,
  });

  bool get isProcessing => status == 'processing' || status == 'queued';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  factory AiJobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AiJobModel(
      id: doc.id,
      facultyId: data['facultyId'] ?? '',
      pdfStorageUrl: data['pdfStorageUrl'] ?? '',
      pdfFileName: data['pdfFileName'] ?? '',
      courseId: data['courseId'],
      moduleId: data['moduleId'],
      status: data['status'] ?? 'queued',
      quizId: data['quizId'],
      errorMessage: data['errorMessage'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'facultyId': facultyId,
      'pdfStorageUrl': pdfStorageUrl,
      'pdfFileName': pdfFileName,
      'courseId': courseId,
      'moduleId': moduleId,
      'status': status,
      'quizId': quizId,
      'errorMessage': errorMessage,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/models/progress_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class ProgressModel {
  final String id;
  final String traineeId;
  final String courseId;
  final List<String> completedModuleIds;
  final Map<String, double> quizScores; // quizId → percentage
  final DateTime? lastAccessedAt;
  final double overallProgress; // 0.0 → 1.0

  const ProgressModel({
    required this.id,
    required this.traineeId,
    required this.courseId,
    this.completedModuleIds = const [],
    this.quizScores = const {},
    this.lastAccessedAt,
    this.overallProgress = 0.0,
  });

  int get completedCount => completedModuleIds.length;

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      id: doc.id,
      traineeId: data['traineeId'] ?? '',
      courseId: data['courseId'] ?? '',
      completedModuleIds: List<String>.from(data['completedModuleIds'] ?? []),
      quizScores: Map<String, double>.from(
        (data['quizScores'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp?)?.toDate(),
      overallProgress: (data['overallProgress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'traineeId': traineeId,
      'courseId': courseId,
      'completedModuleIds': completedModuleIds,
      'quizScores': quizScores,
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'overallProgress': overallProgress,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/models/academy_settings_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class AcademyLocationModel {
  final double latitude;
  final double longitude;
  final double geofenceRadiusMeters;
  final String address;
  final DateTime? updatedAt;

  const AcademyLocationModel({
    required this.latitude,
    required this.longitude,
    this.geofenceRadiusMeters = 200.0,
    required this.address,
    this.updatedAt,
  });

  factory AcademyLocationModel.fromFirestore(Map<String, dynamic> data) {
    return AcademyLocationModel(
      latitude: (data['latitude'] ?? 17.0053).toDouble(),
      longitude: (data['longitude'] ?? 81.7800).toDouble(),
      geofenceRadiusMeters: (data['geofenceRadiusMeters'] ?? 200.0).toDouble(),
      address: data['address'] ?? 'Rajamahendravaram, AP',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadiusMeters': geofenceRadiusMeters,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AcademyInfoModel {
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? website;
  final String? about;

  const AcademyInfoModel({
    this.name = 'A.P. State Forest Academy',
    this.address = 'R.F.R. Complex, Lalacheruvu\nRajamahendravaram – 533106\nAndhra Pradesh, India',
    this.phone,
    this.email,
    this.website,
    this.about,
  });

  factory AcademyInfoModel.fromFirestore(Map<String, dynamic> data) {
    return AcademyInfoModel(
      name: data['name'] ?? 'A.P. State Forest Academy',
      address: data['address'] ?? '',
      phone: data['phone'],
      email: data['email'],
      website: data['website'],
      about: data['about'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'about': about,
    };
  }
}
