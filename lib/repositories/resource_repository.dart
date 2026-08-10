// ─────────────────────────────────────────────────────────────────────────────
// lib/repositories/resource_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource_model.dart';
import '../models/other_models.dart';
import '../core/constants/app_constants.dart';

class ResourceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _resources => _db.collection(AppConstants.colResources);
  CollectionReference get _categories => _db.collection(AppConstants.colCategories);
  CollectionReference get _announcements => _db.collection(AppConstants.colAnnouncements);

  // ── Resources ─────────────────────────────────────────────────────────────

  Stream<List<ResourceModel>> getPublicResources() {
    return _resources
        .where('visibility', isEqualTo: 'public')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ResourceModel.fromFirestore).toList());
  }

  Stream<List<ResourceModel>> getResourcesByCategory(String categoryId) {
    return _resources
        .where('categoryId', isEqualTo: categoryId)
        .where('visibility', isEqualTo: 'public')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ResourceModel.fromFirestore).toList());
  }

  Stream<List<ResourceModel>> getCourseResources(String courseId) {
    return _resources
        .where('courseId', isEqualTo: courseId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ResourceModel.fromFirestore).toList());
  }

  Future<String> addResource(ResourceModel resource) async {
    final doc = await _resources.add(resource.toFirestore());
    return doc.id;
  }

  Future<void> incrementDownloadCount(String resourceId) async {
    await _resources.doc(resourceId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  Future<List<ResourceModel>> searchResources(String query) async {
    final snapshot = await _resources.where('visibility', isEqualTo: 'public').get();
    final q = query.toLowerCase();
    return snapshot.docs
        .map(ResourceModel.fromFirestore)
        .where((r) =>
            r.title.toLowerCase().contains(q) ||
            (r.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Stream<List<CategoryModel>> getCategories() {
    return _categories
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(CategoryModel.fromFirestore).toList());
  }

  Future<String> addCategory(CategoryModel category) async {
    final doc = await _categories.add(category.toFirestore());
    return doc.id;
  }

  Future<void> updateCategory(String id, Map<String, dynamic> updates) async {
    await _categories.doc(id).update(updates);
  }

  // ── Announcements ─────────────────────────────────────────────────────────

  Stream<List<AnnouncementModel>> getAnnouncements({String? audience}) {
    Query query = _announcements.orderBy('createdAt', descending: true);
    if (audience != null && audience != 'all') {
      query = query.where('audience', whereIn: ['all', audience]);
    }
    return query
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map(AnnouncementModel.fromFirestore).toList());
  }

  Future<String> addAnnouncement(AnnouncementModel ann) async {
    final doc = await _announcements.add(ann.toFirestore());
    return doc.id;
  }

  Future<void> deleteAnnouncement(String id) async {
    await _announcements.doc(id).delete();
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> addBookmark({
    required String traineeId,
    required String resourceId,
    required String resourceType,
  }) async {
    await _db.collection(AppConstants.colBookmarks).add({
      'traineeId': traineeId,
      'resourceId': resourceId,
      'resourceType': resourceType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _db.collection(AppConstants.colBookmarks).doc(bookmarkId).delete();
  }

  Stream<List<Map<String, dynamic>>> getTraineeBookmarks(String traineeId) {
    return _db
        .collection(AppConstants.colBookmarks)
        .where('traineeId', isEqualTo: traineeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
            .toList());
  }
}
