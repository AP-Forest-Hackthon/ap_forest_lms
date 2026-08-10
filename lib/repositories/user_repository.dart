// ─────────────────────────────────────────────────────────────────────────────
// lib/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/other_models.dart';
import '../core/constants/app_constants.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection(AppConstants.colUsers);

  // ── Get User ──────────────────────────────────────────────────────────────

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ── Trainees / Students ───────────────────────────────────────────────────

  Stream<List<UserModel>> getAllTrainees() {
    return _users
        .where('role', isEqualTo: AppConstants.roleTrainee)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  Future<bool> isStudentIdTaken(String studentId) async {
    final snap = await _users
        .where('studentId', isEqualTo: studentId.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Faculty & Faculty Requests ────────────────────────────────────────────

  Stream<List<UserModel>> getAllFaculty() {
    return _users
        .where('role', isEqualTo: AppConstants.roleFaculty)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  Stream<List<UserModel>> getFacultyByStatus(String status) {
    return _users
        .where('role', isEqualTo: AppConstants.roleFaculty)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  Stream<List<UserModel>> getPendingFacultyRequests() {
    return getFacultyByStatus('pending');
  }

  Future<void> approveFaculty(String uid) async {
    await _users.doc(uid).update({
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectFaculty(String uid) async {
    await _users.doc(uid).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<UserModel>> getFacultyByCourse(String courseId) async {
    final snap = await _users
        .where('role', isEqualTo: AppConstants.roleFaculty)
        .where('assignedCourseIds', arrayContains: courseId)
        .get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _users.doc(uid).update(updates);
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _users.doc(uid).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignCourseToFaculty(String facultyId, String courseId) async {
    await _users.doc(facultyId).update({
      'assignedCourseIds': FieldValue.arrayUnion([courseId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Academy Settings ──────────────────────────────────────────────────────

  Future<AcademyLocationModel?> getAcademyLocation() async {
    final doc = await _db
        .collection(AppConstants.colAcademySettings)
        .doc(AppConstants.docAcademyLocation)
        .get();
    if (!doc.exists) return null;
    return AcademyLocationModel.fromFirestore(doc.data()!);
  }

  Future<void> updateAcademyLocation(AcademyLocationModel location) async {
    await _db
        .collection(AppConstants.colAcademySettings)
        .doc(AppConstants.docAcademyLocation)
        .set(location.toFirestore(), SetOptions(merge: true));
  }

  Future<AcademyInfoModel?> getAcademyInfo() async {
    final doc = await _db
        .collection(AppConstants.colAcademySettings)
        .doc(AppConstants.docAcademyInfo)
        .get();
    if (!doc.exists) return null;
    return AcademyInfoModel.fromFirestore(doc.data()!);
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<void> updateProgress({
    required String traineeId,
    required String courseId,
    required String moduleId,
  }) async {
    final progressId = '${traineeId}_$courseId';
    final ref = _db.collection(AppConstants.colProgress).doc(progressId);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.update({
        'completedModuleIds': FieldValue.arrayUnion([moduleId]),
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'traineeId': traineeId,
        'courseId': courseId,
        'completedModuleIds': [moduleId],
        'quizScores': {},
        'overallProgress': 0.0,
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<ProgressModel?> getCourseProgress(
    String traineeId,
    String courseId,
  ) async {
    final doc = await _db
        .collection(AppConstants.colProgress)
        .doc('${traineeId}_$courseId')
        .get();
    if (!doc.exists) return null;
    return ProgressModel.fromFirestore(doc);
  }

  Stream<List<ProgressModel>> getAllProgress(String traineeId) {
    return _db
        .collection(AppConstants.colProgress)
        .where('traineeId', isEqualTo: traineeId)
        .snapshots()
        .map((s) => s.docs.map(ProgressModel.fromFirestore).toList());
  }

  // ── Timetable ─────────────────────────────────────────────────────────────

  Stream<List<TimetableModel>> getTimetable({DateTime? from, DateTime? to}) {
    Query query = _db.collection(AppConstants.colTimetable);
    if (from != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }
    return query
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map(TimetableModel.fromFirestore).toList());
  }

  Future<String> addTimetableEntry(TimetableModel entry) async {
    final doc = await _db.collection(AppConstants.colTimetable).add(entry.toFirestore());
    return doc.id;
  }
}
