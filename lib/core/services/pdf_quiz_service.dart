// ─────────────────────────────────────────────────────────────────────────────
// lib/core/services/pdf_quiz_service.dart
// Calls Python FastAPI backend to generate AI quiz questions from PDF.
// The Groq API key NEVER appears in Flutter — it lives only in the backend.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import '../../models/quiz_model.dart';

class PdfQuizService {
  String get _baseUrl {
    return dotenv.env[AppConstants.envBackendUrl] ?? AppConstants.backendFallbackUrl;
  }

  // ── Generate Quiz from PDF URL ─────────────────────────────────────────────

  /// [pdfStorageUrl]: Firebase Storage download URL of the PDF
  /// [quizTitle]: Default quiz title (from PDF filename)
  /// [maxQuestions]: How many MCQs to generate (default 10)
  ///
  /// Returns list of parsed QuestionModel objects for faculty review.
  Future<({List<QuestionModel> questions, String suggestedTitle})> generateQuizFromPdf({
    required String pdfStorageUrl,
    required String quizTitle,
    int maxQuestions = 10,
  }) async {
    final url = Uri.parse('$_baseUrl${AppConstants.generateQuizEndpoint}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'pdf_url': pdfStorageUrl,
          'quiz_title': quizTitle,
          'max_questions': maxQuestions,
        }),
      ).timeout(const Duration(minutes: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseResponse(data);
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw Exception('PDF processing error: ${error['detail'] ?? 'Invalid PDF'}');
      } else {
        throw Exception(
          'Backend error (${response.statusCode}): ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Cannot reach backend server: ${e.message}\n'
          'Make sure the Python backend is running at $_baseUrl');
    } catch (e) {
      rethrow;
    }
  }

  // ── AI Learning Assistant ──────────────────────────────────────────────────

  Future<String> askAssistant({
    required String question,
    String? contextCourseId,
  }) async {
    final url = Uri.parse('$_baseUrl${AppConstants.aiAssistantEndpoint}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'course_id': contextCourseId,
          'domain': 'forestry education',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['answer'] ?? 'No response received.';
      } else {
        throw Exception('Assistant error: ${response.body}');
      }
    } catch (e) {
      throw Exception('AI assistant unavailable: $e');
    }
  }

  // ── Health Check ──────────────────────────────────────────────────────────

  Future<bool> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl${AppConstants.healthEndpoint}'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Response Parser ───────────────────────────────────────────────────────

  ({List<QuestionModel> questions, String suggestedTitle}) _parseResponse(
    Map<String, dynamic> data,
  ) {
    final suggestedTitle = data['title'] as String? ?? 'AI Generated Quiz';
    final questionsRaw = data['questions'] as List<dynamic>? ?? [];

    if (questionsRaw.isEmpty) {
      throw Exception('No questions were generated. Try a different PDF.');
    }

    final questions = <QuestionModel>[];
    for (int i = 0; i < questionsRaw.length; i++) {
      final q = questionsRaw[i] as Map<String, dynamic>;

      // Validate each question has required fields
      if (q['question'] == null || q['options'] == null || q['correctAnswer'] == null) {
        continue; // skip malformed questions
      }

      final options = List<String>.from(q['options'] ?? []);
      if (options.length < 2) continue; // must have at least 2 options

      questions.add(
        QuestionModel(
          id: 'q_$i',
          quizId: '',
          question: q['question'].toString(),
          options: options,
          correctAnswer: q['correctAnswer'].toString(),
          explanation: q['explanation']?.toString(),
          order: i,
          source: 'ai',
        ),
      );
    }

    if (questions.isEmpty) {
      throw Exception(
        'Could not parse any valid questions from AI response. Please retry.',
      );
    }

    return (questions: questions, suggestedTitle: suggestedTitle);
  }
}
