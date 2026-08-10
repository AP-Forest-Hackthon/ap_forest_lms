// ─────────────────────────────────────────────────────────────────────────────
// lib/core/services/storage_service.dart
// Firebase Storage upload/download service.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Upload PDF ─────────────────────────────────────────────────────────────

  Future<String> uploadPdf({
    required File file,
    required String folder,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref('$folder$fileName');
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'application/pdf'),
    );

    uploadTask.snapshotEvents.listen((snapshot) {
      if (onProgress != null) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      }
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // ── Upload Resource PDF ────────────────────────────────────────────────────

  Future<String> uploadResourcePdf({
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    return uploadPdf(
      file: file,
      folder: AppConstants.storageResourcePdfs,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  // ── Upload Quiz Source PDF ─────────────────────────────────────────────────

  Future<String> uploadQuizSourcePdf({
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    return uploadPdf(
      file: file,
      folder: AppConstants.storageQuizSourcePdfs,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  // ── Upload Profile Photo ───────────────────────────────────────────────────

  Future<String> uploadProfilePhoto({
    required File file,
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    final ext = path.extension(file.path);
    final ref = _storage.ref('${AppConstants.storageProfilePhotos}$userId$ext');
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    uploadTask.snapshotEvents.listen((snapshot) {
      if (onProgress != null) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // ── Upload Course Thumbnail ────────────────────────────────────────────────

  Future<String> uploadCourseThumbnail({
    required File file,
    required String courseId,
  }) async {
    final ext = path.extension(file.path);
    final ref = _storage
        .ref('${AppConstants.storageCourseThumbnails}$courseId$ext');
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  // ── Delete File ────────────────────────────────────────────────────────────

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // File may already be deleted
    }
  }

  // ── Get Download URL ───────────────────────────────────────────────────────

  Future<String> getDownloadUrl(String storagePath) async {
    final ref = _storage.ref(storagePath);
    return await ref.getDownloadURL();
  }
}
