// ─────────────────────────────────────────────────────────────────────────────
// lib/repositories/course_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../core/constants/app_constants.dart';

class CourseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _courses => _db.collection(AppConstants.colCourses);

  // ── Queries ───────────────────────────────────────────────────────────────

  Stream<List<CourseModel>> getPublishedCourses() {
    return _courses
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CourseModel.fromFirestore).toList());
  }

  Stream<List<CourseModel>> getCoursesByCategory(String categoryId) {
    return _courses
        .where('status', isEqualTo: 'published')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((s) => s.docs.map(CourseModel.fromFirestore).toList());
  }

  Stream<List<CourseModel>> getFacultyCourses(String facultyId) {
    return _courses
        .where('facultyIds', arrayContains: facultyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CourseModel.fromFirestore).toList());
  }

  Future<List<CourseModel>> getFacultyCoursesOnce(String facultyId) async {
    final snapshot = await _courses
        .where('facultyIds', arrayContains: facultyId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(CourseModel.fromFirestore).toList();
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    final doc = await _courses.doc(courseId).get();
    if (!doc.exists) return null;
    return CourseModel.fromFirestore(doc);
  }

  // ── Modules ───────────────────────────────────────────────────────────────

  Stream<List<ModuleModel>> getCourseModules(String courseId) {
    return _courses
        .doc(courseId)
        .collection(AppConstants.colModules)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(ModuleModel.fromFirestore).toList());
  }

  Future<ModuleModel?> getModuleById(String courseId, String moduleId) async {
    final doc = await _courses
        .doc(courseId)
        .collection(AppConstants.colModules)
        .doc(moduleId)
        .get();
    if (!doc.exists) return null;
    return ModuleModel.fromFirestore(doc);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<String> createCourse(CourseModel course) async {
    final doc = await _courses.add(course.toFirestore());
    return doc.id;
  }

  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _courses.doc(courseId).update(updates);
  }

  Future<String> addModule(String courseId, ModuleModel module) async {
    final doc = await _courses
        .doc(courseId)
        .collection(AppConstants.colModules)
        .add(module.toFirestore());
    // Update module count
    await _courses.doc(courseId).update({
      'moduleCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> updates,
  ) async {
    await _courses
        .doc(courseId)
        .collection(AppConstants.colModules)
        .doc(moduleId)
        .update(updates);
  }

  Future<void> deleteDraftCourse(String courseId) async {
    // Only allow deleting draft courses
    final doc = await _courses.doc(courseId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    if (data['status'] == 'published') {
      throw Exception('Cannot delete a published course. Unpublish it first.');
    }
    await _courses.doc(courseId).delete();
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    final snapshot = await _courses
        .where('status', isEqualTo: 'published')
        .get();

    final q = query.toLowerCase();
    return snapshot.docs
        .map(CourseModel.fromFirestore)
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
  }
}
