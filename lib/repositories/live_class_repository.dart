// ─────────────────────────────────────────────────────────────────────────────
// lib/repositories/live_class_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/live_class_model.dart';

class LiveClassRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _liveClasses => _db.collection('liveClasses');

  Stream<List<LiveClassModel>> getUpcomingLiveClasses() {
    return _liveClasses
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map(LiveClassModel.fromFirestore).toList());
  }

  Stream<List<LiveClassModel>> getFacultyLiveClasses(String facultyId) {
    return _liveClasses
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map(LiveClassModel.fromFirestore).toList());
  }

  Future<String> createLiveClass(LiveClassModel liveClass) async {
    final doc = await _liveClasses.add(liveClass.toFirestore());
    return doc.id;
  }

  Future<void> updateLiveClassLinks({
    required String id,
    String? googleMeetUrl,
    String? zoomUrl,
  }) async {
    final Map<String, dynamic> updates = {};
    if (googleMeetUrl != null) updates['googleMeetUrl'] = googleMeetUrl.trim();
    if (zoomUrl != null) updates['zoomUrl'] = zoomUrl.trim();
    await _liveClasses.doc(id).update(updates);
  }

  Future<void> deleteLiveClass(String id) async {
    await _liveClasses.doc(id).delete();
  }
}
