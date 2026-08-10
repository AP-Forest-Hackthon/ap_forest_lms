// ─────────────────────────────────────────────────────────────────────────────
// lib/features/faculty/ai_quiz_generator/ai_quiz_generator_screen.dart
//
// P0 CRITICAL FEATURE — PDF → AI Quiz Generator
//
// Flow:
//   1. Faculty selects/picks PDF
//   2. Upload to Firebase Storage
//   3. Call Python FastAPI backend → Groq LLM generates MCQs
//   4. Show processing status
//   5. On success → navigate to QuizReviewScreen
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/pdf_quiz_service.dart';
import '../../../models/quiz_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/course_repository.dart';
import '../../../repositories/quiz_repository.dart';

class AiQuizGeneratorScreen extends StatefulWidget {
  const AiQuizGeneratorScreen({super.key});

  @override
  State<AiQuizGeneratorScreen> createState() => _AiQuizGeneratorScreenState();
}

class _AiQuizGeneratorScreenState extends State<AiQuizGeneratorScreen> {
  final _storageService = StorageService();
  final _pdfQuizService = PdfQuizService();
  final _quizRepo = QuizRepository();
  final _courseRepo = CourseRepository();

  File? _selectedFile;
  String? _fileName;
  double _uploadProgress = 0;
  String? _selectedCourseId;
  String? _selectedCourseName;
  int _maxQuestions = 8;

  // State machine
  _GeneratorState _state = _GeneratorState.idle;
  String _statusMessage = '';
  String? _errorMessage;
  String? _generatedQuizId;

  List<Map<String, String>> _facultyCourses = [];

  @override
  void initState() {
    super.initState();
    _loadFacultyCourses();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    final healthy = await _pdfQuizService.checkBackendHealth();
    if (!healthy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ AI backend not reachable. Make sure the Python server is running.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _loadFacultyCourses() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final courses = await _courseRepo.getFacultyCoursesOnce(user.uid);
    if (mounted) {
      setState(() {
        _facultyCourses = courses.map((c) => {'id': c.id, 'title': c.title}).toList();
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeInMb = file.lengthSync() / (1024 * 1024);

      if (sizeInMb > AppConstants.maxPdfSizeMb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PDF too large (${sizeInMb.toStringAsFixed(1)} MB). '
                'Max allowed: ${AppConstants.maxPdfSizeMb} MB',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = result.files.single.name;
        _state = _GeneratorState.idle;
        _errorMessage = null;
      });
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedFile == null) {
      _showError('Please select a PDF file first.');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() {
      _state = _GeneratorState.uploading;
      _statusMessage = 'Uploading PDF to secure storage...';
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      // Step 1: Upload PDF to Firebase Storage
      final storageUrl = await _storageService.uploadQuizSourcePdf(
        file: _selectedFile!,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      setState(() {
        _state = _GeneratorState.generating;
        _statusMessage = 'Extracting text from PDF...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _statusMessage = 'Sending to AI for quiz generation (Groq LLM)...');

      // Step 2: Call Python backend → Groq → returns questions
      final result = await _pdfQuizService.generateQuizFromPdf(
        pdfStorageUrl: storageUrl,
        quizTitle: _fileName!.replaceAll('.pdf', ''),
        maxQuestions: _maxQuestions,
      );

      setState(() => _statusMessage = 'Saving draft quiz for your review...');

      // Step 3: Create quiz in Firestore (status = ai_review)
      final quiz = QuizModel(
        id: '',
        courseId: _selectedCourseId,
        title: result.suggestedTitle,
        description: 'AI-generated from: $_fileName',
        createdBy: user.uid,
        sourceResourceId: storageUrl,
        status: AppConstants.quizAiReview,
        questionCount: result.questions.length,
        passingScore: 60,
        createdAt: DateTime.now(),
      );

      final quizId = await _quizRepo.createQuiz(quiz);

      // Step 4: Save questions to Firestore
      await _quizRepo.saveAiGeneratedQuestions(quizId, result.questions);

      setState(() {
        _state = _GeneratorState.completed;
        _statusMessage = '${result.questions.length} questions generated successfully!';
        _generatedQuizId = quizId;
      });
    } catch (e) {
      setState(() {
        _state = _GeneratorState.failed;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _statusMessage = 'Generation failed.';
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Quiz Generator'),
        backgroundColor: AppColors.primary,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Groq AI',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 20),
            _buildPdfSelector(),
            const SizedBox(height: 16),
            _buildCourseSelector(),
            const SizedBox(height: 16),
            _buildQuestionCountSelector(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            const SizedBox(height: 20),
            if (_state != _GeneratorState.idle) _buildStatusCard(),
            if (_state == _GeneratorState.completed) ...[
              const SizedBox(height: 16),
              _buildSuccessActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDF → AI Quiz Generation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Upload a PDF and let Groq AI generate MCQ questions. You review and edit before publishing.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select PDF Document',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _state == _GeneratorState.uploading || _state == _GeneratorState.generating
              ? null
              : _pickPdf,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _selectedFile != null ? AppColors.primarySurface : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedFile != null ? AppColors.primary : AppColors.border,
                style: _selectedFile != null ? BorderStyle.solid : BorderStyle.solid,
                width: _selectedFile != null ? 1.5 : 1,
              ),
            ),
            child: _selectedFile == null
                ? const Column(
                    children: [
                      Icon(Icons.upload_file, size: 40, color: AppColors.textHint),
                      SizedBox(height: 8),
                      Text(
                        'Tap to select PDF',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Supported: PDF up to 20MB',
                        style: TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(_selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _selectedFile = null;
                          _fileName = null;
                          _state = _GeneratorState.idle;
                        }),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign to Course (Optional)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCourseId,
          hint: const Text('Select course (optional)'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.menu_book_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('No course selected')),
            ..._facultyCourses.map(
              (c) => DropdownMenuItem(value: c['id'], child: Text(c['title']!)),
            ),
          ],
          onChanged: (v) => setState(() {
            _selectedCourseId = v;
            _selectedCourseName = _facultyCourses
                .firstWhere((c) => c['id'] == v, orElse: () => {})['title'];
          }),
        ),
      ],
    );
  }

  Widget _buildQuestionCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Number of Questions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_maxQuestions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _maxQuestions.toDouble(),
          min: 3,
          max: 15,
          divisions: 12,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.progressTrack,
          onChanged: (v) => setState(() => _maxQuestions = v.toInt()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('3 min', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            const Text('15 max', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final isProcessing = _state == _GeneratorState.uploading ||
        _state == _GeneratorState.generating;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : _generateQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          isProcessing ? 'Generating...' : 'Generate Quiz with AI',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final (icon, color, bg) = switch (_state) {
      _GeneratorState.uploading => (Icons.cloud_upload, AppColors.info, AppColors.infoLight),
      _GeneratorState.generating => (Icons.auto_awesome, AppColors.primary, AppColors.primarySurface),
      _GeneratorState.completed => (Icons.check_circle, AppColors.success, AppColors.successLight),
      _GeneratorState.failed => (Icons.error, AppColors.error, AppColors.errorLight),
      _ => (Icons.info, AppColors.info, AppColors.infoLight),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_state == _GeneratorState.uploading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            Text(
              '${(_uploadProgress * 100).toInt()}% uploaded',
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
          if (_state == _GeneratorState.generating) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _generateQuiz,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessActions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.accentDark),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Review all questions carefully before publishing. You can edit, delete, or add questions.',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_generatedQuizId != null) {
                context.go('/faculty/quizzes/$_generatedQuizId/review');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.rate_review, color: AppColors.textOnAccent),
            label: const Text(
              'Review Generated Quiz',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textOnAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _GeneratorState { idle, uploading, generating, completed, failed }
