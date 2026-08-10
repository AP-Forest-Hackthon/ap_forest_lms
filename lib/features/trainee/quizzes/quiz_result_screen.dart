import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  final String quizId;
  final Object? extra;
  const QuizResultScreen({super.key, required this.quizId, this.extra});

  @override
  Widget build(BuildContext context) {
    final data = extra as Map<String, dynamic>?;
    final attempt = data?['attempt'] as QuizAttemptModel?;
    final scoreText = attempt != null ? '${attempt.percentage.toStringAsFixed(1)}%' : 'Completed';
    final detailsText = attempt != null ? '${attempt.correctCount} / ${attempt.totalQuestions} correct' : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quiz Result'), backgroundColor: AppColors.primary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              attempt?.passed == true ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: attempt?.passed == true ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              attempt?.passed == true ? 'Passed!' : 'Failed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: attempt?.passed == true ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scoreText,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (detailsText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                detailsText,
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.quizList),
              child: const Text('Back to Quizzes'),
            ),
          ],
        ),
      ),
    );
  }
}
