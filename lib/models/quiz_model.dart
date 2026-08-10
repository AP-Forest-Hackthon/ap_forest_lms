// ─────────────────────────────────────────────────────────────────────────────
// lib/models/quiz_model.dart  &  question_model.dart  &  quiz_attempt_model.dart
// All quiz-related models in one file for simplicity.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

// ── QuestionModel ─────────────────────────────────────────────────────────────

class QuestionModel {
  final String id;
  final String quizId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int order;
  final String source; // 'manual' | 'ai'

  const QuestionModel({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.order = 0,
    this.source = 'manual',
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      explanation: data['explanation'],
      order: data['order'] ?? 0,
      source: data['source'] ?? 'manual',
    );
  }

  factory QuestionModel.fromMap(Map<String, dynamic> data, {String? id, String? quizId}) {
    return QuestionModel(
      id: id ?? '',
      quizId: quizId ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      explanation: data['explanation'],
      order: data['order'] ?? 0,
      source: data['source'] ?? 'ai',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'quizId': quizId,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'order': order,
      'source': source,
    };
  }

  QuestionModel copyWith({
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    int? order,
  }) {
    return QuestionModel(
      id: id,
      quizId: quizId,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      order: order ?? this.order,
      source: source,
    );
  }
}

// ── QuizModel ─────────────────────────────────────────────────────────────────

class QuizModel {
  final String id;
  final String? courseId;
  final String? moduleId;
  final String title;
  final String? description;
  final String createdBy;
  final String? sourceResourceId;
  final String status; // draft | ai_review | published
  final int questionCount;
  final int? timeLimitMinutes;
  final int passingScore; // percentage
  final DateTime? createdAt;
  final DateTime? publishedAt;

  const QuizModel({
    required this.id,
    this.courseId,
    this.moduleId,
    required this.title,
    this.description,
    required this.createdBy,
    this.sourceResourceId,
    this.status = 'draft',
    this.questionCount = 0,
    this.timeLimitMinutes,
    this.passingScore = 60,
    this.createdAt,
    this.publishedAt,
  });

  bool get isPublished => status == 'published';
  bool get isAiReview => status == 'ai_review';
  bool get isDraft => status == 'draft';

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      courseId: data['courseId'],
      moduleId: data['moduleId'],
      title: data['title'] ?? '',
      description: data['description'],
      createdBy: data['createdBy'] ?? '',
      sourceResourceId: data['sourceResourceId'],
      status: data['status'] ?? 'draft',
      questionCount: data['questionCount'] ?? 0,
      timeLimitMinutes: data['timeLimitMinutes'],
      passingScore: data['passingScore'] ?? 60,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'moduleId': moduleId,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'sourceResourceId': sourceResourceId,
      'status': status,
      'questionCount': questionCount,
      'timeLimitMinutes': timeLimitMinutes,
      'passingScore': passingScore,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
    };
  }

  QuizModel copyWith({
    String? title,
    String? description,
    String? status,
    int? questionCount,
    int? timeLimitMinutes,
    int? passingScore,
  }) {
    return QuizModel(
      id: id,
      courseId: courseId,
      moduleId: moduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy,
      sourceResourceId: sourceResourceId,
      status: status ?? this.status,
      questionCount: questionCount ?? this.questionCount,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingScore: passingScore ?? this.passingScore,
      createdAt: createdAt,
      publishedAt: publishedAt,
    );
  }
}

// ── QuizAttemptModel ──────────────────────────────────────────────────────────

class QuizAttemptModel {
  final String id;
  final String quizId;
  final String traineeId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int correctCount;
  final int wrongCount;
  final Map<String, String> answers; // questionId → selectedAnswer
  final bool passed;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int? timeTakenSeconds;

  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.traineeId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.correctCount,
    required this.wrongCount,
    required this.answers,
    required this.passed,
    this.startedAt,
    this.submittedAt,
    this.timeTakenSeconds,
  });

  factory QuizAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttemptModel(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      traineeId: data['traineeId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      correctCount: data['correctCount'] ?? 0,
      wrongCount: data['wrongCount'] ?? 0,
      answers: Map<String, String>.from(data['answers'] ?? {}),
      passed: data['passed'] ?? false,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      timeTakenSeconds: data['timeTakenSeconds'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'quizId': quizId,
      'traineeId': traineeId,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'answers': answers,
      'passed': passed,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'submittedAt': submittedAt != null
          ? Timestamp.fromDate(submittedAt!)
          : FieldValue.serverTimestamp(),
      'timeTakenSeconds': timeTakenSeconds,
    };
  }
}
