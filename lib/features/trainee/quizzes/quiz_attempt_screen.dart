// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trainee/quizzes/quiz_attempt_screen.dart
// Trainee takes quiz — timer, MCQ UI, submit, score calc, save to Firestore.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/quiz_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/quiz_repository.dart';

class QuizAttemptScreen extends StatefulWidget {
  final String quizId;
  const QuizAttemptScreen({super.key, required this.quizId});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  final _quizRepo = QuizRepository();

  QuizModel? _quiz;
  List<QuestionModel> _questions = [];
  final Map<int, int> _selectedAnswers = {}; // questionIndex → optionIndex
  bool _isLoading = true;
  bool _isSubmitting = false;

  int _currentPage = 0;
  int _secondsElapsed = 0;
  Timer? _timer;
  final DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final quiz = await _quizRepo.getQuizById(widget.quizId);
    final questions = await _quizRepo.getQuizQuestions(widget.quizId);
    if (mounted) {
      setState(() {
        _quiz = quiz;
        _questions = questions;
        _isLoading = false;
      });
      _startTimer(quiz?.timeLimitMinutes);
    }
  }

  void _startTimer(int? limitMinutes) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsElapsed++);

      if (limitMinutes != null && _secondsElapsed >= limitMinutes * 60) {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    // Confirm submit if not all answered
    if (_selectedAnswers.length < _questions.length) {
      final unanswered = _questions.length - _selectedAnswers.length;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submit Quiz?'),
          content: Text('$unanswered question(s) unanswered. Submit anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Continue')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);
    _timer?.cancel();

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Calculate score
    int correct = 0;
    final answers = <String, String>{};
    for (int i = 0; i < _questions.length; i++) {
      final selectedIdx = _selectedAnswers[i];
      if (selectedIdx != null) {
        final selectedAnswer = _questions[i].options[selectedIdx];
        answers[_questions[i].id] = selectedAnswer;
        if (selectedAnswer == _questions[i].correctAnswer) correct++;
      }
    }

    final total = _questions.length;
    final percentage = total > 0 ? (correct / total) * 100.0 : 0.0;
    final passing = _quiz?.passingScore ?? 60;
    final passed = percentage >= passing;

    final attempt = QuizAttemptModel(
      id: '',
      quizId: widget.quizId,
      traineeId: user.uid,
      score: correct,
      totalQuestions: total,
      percentage: percentage,
      correctCount: correct,
      wrongCount: total - correct,
      answers: answers,
      passed: passed,
      startedAt: _startedAt,
      submittedAt: DateTime.now(),
      timeTakenSeconds: _secondsElapsed,
    );

    final attemptId = await _quizRepo.saveAttempt(attempt);

    if (mounted) {
      context.go(
        '/trainee/quizzes/${widget.quizId}/result',
        extra: {
          'attempt': attempt,
          'questions': _questions,
        },
      );
    }
  }

  String get _timerDisplay {
    final m = _secondsElapsed ~/ 60;
    final s = _secondsElapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_quiz?.title ?? 'Quiz'),
        backgroundColor: AppColors.primary,
        actions: [
          // Timer
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _timerDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          _buildProgress(),
          // Question
          Expanded(child: _buildQuestion()),
          // Navigation
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final answered = _selectedAnswers.length;
    final total = _questions.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentPage + 1} of $total',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Text(
                '$answered answered',
                style: TextStyle(
                  fontSize: 13,
                  color: answered == total ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: total > 0 ? (_currentPage + 1) / total : 0,
            backgroundColor: AppColors.progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    if (_questions.isEmpty) return const Center(child: Text('No questions found.'));
    final q = _questions[_currentPage];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              q.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Options
          ...List.generate(q.options.length, (i) {
            final label = String.fromCharCode(65 + i);
            final isSelected = _selectedAnswers[_currentPage] == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedAnswers[_currentPage] = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primarySurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.options[i],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == _questions.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      color: AppColors.surface,
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentPage--),
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text('Previous'),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),
          Expanded(
            flex: isLast ? 2 : 1,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : isLast
                      ? _submitQuiz
                      : () => setState(() => _currentPage++),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppColors.success : AppColors.primary,
              ),
              icon: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(isLast ? Icons.check : Icons.arrow_forward_ios, size: 16, color: Colors.white),
              label: Text(
                isLast ? 'Submit Quiz' : 'Next',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
