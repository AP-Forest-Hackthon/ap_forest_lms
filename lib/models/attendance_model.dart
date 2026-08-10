// ─────────────────────────────────────────────────────────────────────────────
// lib/models/attendance_model.dart
// Data model for Trainee GPS attendance records.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isInsideGeofence;
  final String status; // 'Present', 'Absent', 'Late'

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isInsideGeofence,
    required this.status,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return AttendanceRecord(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      isInsideGeofence: map['isInsideGeofence'] ?? false,
      status: map['status'] ?? 'Absent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'isInsideGeofence': isInsideGeofence,
      'status': status,
    };
  }
}
