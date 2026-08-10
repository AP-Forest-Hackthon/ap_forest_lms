// ─────────────────────────────────────────────────────────────────────────────
// lib/repositories/quiz_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../core/constants/app_constants.dart';

class QuizRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _quizzes => _db.collection(AppConstants.colQuizzes);

  // ── Queries ───────────────────────────────────────────────────────────────

  Stream<List<QuizModel>> getPublishedQuizzes() {
    return _quizzes
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(QuizModel.fromFirestore).toList());
  }

  Stream<List<QuizModel>> getQuizzesByCourse(String courseId) {
    return _quizzes
        .where('courseId', isEqualTo: courseId)
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((s) => s.docs.map(QuizModel.fromFirestore).toList());
  }

  Stream<List<QuizModel>> getFacultyQuizzes(String facultyId) {
    return _quizzes
        .where('createdBy', isEqualTo: facultyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(QuizModel.fromFirestore).toList());
  }

  Stream<List<QuizModel>> getAiReviewQuizzes(String facultyId) {
    return _quizzes
        .where('createdBy', isEqualTo: facultyId)
        .where('status', isEqualTo: AppConstants.quizAiReview)
        .snapshots()
        .map((s) => s.docs.map(QuizModel.fromFirestore).toList());
  }

  Future<QuizModel?> getQuizById(String quizId) async {
    final doc = await _quizzes.doc(quizId).get();
    if (!doc.exists) return null;
    return QuizModel.fromFirestore(doc);
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    final snapshot = await _quizzes
        .doc(quizId)
        .collection(AppConstants.colQuestions)
        .orderBy('order')
        .get();
    return snapshot.docs.map(QuestionModel.fromFirestore).toList();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<String> createQuiz(QuizModel quiz) async {
    final doc = await _quizzes.add(quiz.toFirestore());
    return doc.id;
  }

  Future<void> updateQuiz(String quizId, Map<String, dynamic> updates) async {
    await _quizzes.doc(quizId).update(updates);
  }

  Future<void> addQuestion(String quizId, QuestionModel question) async {
    final q = question.copyWith();
    final data = q.toFirestore();
    data['quizId'] = quizId;
    await _quizzes.doc(quizId).collection(AppConstants.colQuestions).add(data);
    await _quizzes.doc(quizId).update({'questionCount': FieldValue.increment(1)});
  }

  Future<void> updateQuestion(
    String quizId,
    String questionId,
    Map<String, dynamic> updates,
  ) async {
    await _quizzes
        .doc(quizId)
        .collection(AppConstants.colQuestions)
        .doc(questionId)
        .update(updates);
  }

  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _quizzes
        .doc(quizId)
        .collection(AppConstants.colQuestions)
        .doc(questionId)
        .delete();
    await _quizzes.doc(quizId).update({'questionCount': FieldValue.increment(-1)});
  }

  /// Batch-adds AI-generated questions to a quiz (called after faculty review)
  Future<void> saveAiGeneratedQuestions(
    String quizId,
    List<QuestionModel> questions,
  ) async {
    final batch = _db.batch();
    final questionsRef =
        _quizzes.doc(quizId).collection(AppConstants.colQuestions);

    for (int i = 0; i < questions.length; i++) {
      final qData = questions[i].toFirestore();
      qData['quizId'] = quizId;
      qData['order'] = i;
      batch.set(questionsRef.doc(), qData);
    }

    batch.update(_quizzes.doc(quizId), {
      'questionCount': questions.length,
    });

    await batch.commit();
  }

  Future<void> publishQuiz(String quizId) async {
    await _quizzes.doc(quizId).update({
      'status': AppConstants.quizPublished,
      'publishedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unpublishQuiz(String quizId) async {
    await _quizzes.doc(quizId).update({'status': AppConstants.quizDraft});
  }

  // ── Attempts ──────────────────────────────────────────────────────────────

  Future<String> saveAttempt(QuizAttemptModel attempt) async {
    final doc = await _db
        .collection(AppConstants.colQuizAttempts)
        .add(attempt.toFirestore());
    return doc.id;
  }

  Future<List<QuizAttemptModel>> getTraineeAttempts(String traineeId) async {
    final snapshot = await _db
        .collection(AppConstants.colQuizAttempts)
        .where('traineeId', isEqualTo: traineeId)
        .orderBy('submittedAt', descending: true)
        .get();
    return snapshot.docs.map(QuizAttemptModel.fromFirestore).toList();
  }

  Future<QuizAttemptModel?> getBestAttempt(
    String quizId,
    String traineeId,
  ) async {
    final snapshot = await _db
        .collection(AppConstants.colQuizAttempts)
        .where('quizId', isEqualTo: quizId)
        .where('traineeId', isEqualTo: traineeId)
        .orderBy('percentage', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return QuizAttemptModel.fromFirestore(snapshot.docs.first);
  }

  // Faculty: quiz performance stats
  Future<Map<String, dynamic>> getQuizStats(String quizId) async {
    final snapshot = await _db
        .collection(AppConstants.colQuizAttempts)
        .where('quizId', isEqualTo: quizId)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'average': 0.0, 'highest': 0.0, 'lowest': 0.0, 'attempts': 0};
    }

    final percentages = snapshot.docs
        .map((d) => (d['percentage'] as num).toDouble())
        .toList();

    final avg = percentages.reduce((a, b) => a + b) / percentages.length;
    final highest = percentages.reduce((a, b) => a > b ? a : b);
    final lowest = percentages.reduce((a, b) => a < b ? a : b);

    return {
      'average': avg,
      'highest': highest,
      'lowest': lowest,
      'attempts': percentages.length,
    };
  }
}
