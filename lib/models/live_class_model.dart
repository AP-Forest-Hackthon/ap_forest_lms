// ─────────────────────────────────────────────────────────────────────────────
// lib/models/live_class_model.dart
// Live class data model supporting Google Meet and Zoom meeting URLs.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class LiveClassModel {
  final String id;
  final String? courseId;
  final String subject;
  final String topic;
  final String facultyId;
  final String? facultyName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? googleMeetUrl;
  final String? zoomUrl;
  final String status; // 'scheduled' | 'live' | 'completed' | 'cancelled'
  final DateTime? createdAt;

  const LiveClassModel({
    required this.id,
    this.courseId,
    required this.subject,
    required this.topic,
    required this.facultyId,
    this.facultyName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.googleMeetUrl,
    this.zoomUrl,
    this.status = 'scheduled',
    this.createdAt,
  });

  bool get hasGoogleMeet => googleMeetUrl != null && googleMeetUrl!.trim().isNotEmpty;
  bool get hasZoom => zoomUrl != null && zoomUrl!.trim().isNotEmpty;

  factory LiveClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LiveClassModel(
      id: doc.id,
      courseId: data['courseId'],
      subject: data['subject'] ?? 'Forest Management',
      topic: data['topic'] ?? '',
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'],
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      googleMeetUrl: data['googleMeetUrl'],
      zoomUrl: data['zoomUrl'],
      status: data['status'] ?? 'scheduled',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'subject': subject,
      'topic': topic,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'googleMeetUrl': googleMeetUrl,
      'zoomUrl': zoomUrl,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
