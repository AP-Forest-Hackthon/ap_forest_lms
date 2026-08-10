// ─────────────────────────────────────────────────────────────────────────────
// lib/features/faculty/quiz_management/quiz_review_screen.dart
//
// P0 CRITICAL — Faculty reviews AI-generated quiz before publishing.
// Every question is editable, deletable. Faculty can add new questions.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/quiz_model.dart';
import '../../../repositories/quiz_repository.dart';

class QuizReviewScreen extends StatefulWidget {
  final String quizId;
  const QuizReviewScreen({super.key, required this.quizId});

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  final _quizRepo = QuizRepository();

  QuizModel? _quiz;
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final quiz = await _quizRepo.getQuizById(widget.quizId);
    final questions = await _quizRepo.getQuizQuestions(widget.quizId);
    if (mounted) {
      setState(() {
        _quiz = quiz;
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  Future<void> _publishQuiz() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one question before publishing.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Quiz'),
        content: Text(
          'Publish "${_quiz?.title}" with ${_questions.length} questions?\n\n'
          'Trainees will be able to attempt this quiz once published.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isPublishing = true);
    try {
      await _quizRepo.publishQuiz(widget.quizId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Quiz published! Trainees can now attempt it.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(RouteNames.facultyQuizList);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publish failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _editQuestion(QuestionModel question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditQuestionSheet(
        question: question,
        onSave: (updated) async {
          await _quizRepo.updateQuestion(widget.quizId, question.id, {
            'question': updated.question,
            'options': updated.options,
            'correctAnswer': updated.correctAnswer,
            'explanation': updated.explanation,
          });
          Navigator.pop(ctx);
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text(
          'Delete this question?\n\n"${question.question.length > 80 ? "${question.question.substring(0, 80)}..." : question.question}"',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _quizRepo.deleteQuestion(widget.quizId, question.id);
      _loadData();
    }
  }

  void _addQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditQuestionSheet(
        question: null,
        onSave: (q) async {
          await _quizRepo.addQuestion(widget.quizId, q.copyWith(order: _questions.length));
          Navigator.pop(ctx);
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Quiz'),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text('Add Q', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildQuizHeader(),
                Expanded(child: _buildQuestionList()),
              ],
            ),
      bottomNavigationBar: _buildPublishBar(),
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.accentDark, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _quiz?.title ?? 'AI Generated Quiz',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_questions.length} questions • Review before publishing',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.warning, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Edit each question carefully. AI may make mistakes. You are responsible for published content.',
                    style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _quiz?.status ?? 'ai_review';
    final (label, color) = switch (status) {
      'published' => ('Published', AppColors.success),
      'ai_review' => ('AI Draft', AppColors.warning),
      _ => ('Draft', AppColors.textHint),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildQuestionList() {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('No questions yet.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _questions.length,
      itemBuilder: (ctx, i) => _QuestionCard(
        question: _questions[i],
        index: i + 1,
        onEdit: () => _editQuestion(_questions[i]),
        onDelete: () => _deleteQuestion(_questions[i]),
      ),
    );
  }

  Widget _buildPublishBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isPublishing ? null : _publishQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: _isPublishing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.publish, color: Colors.white),
          label: Text(
            _isPublishing ? 'Publishing...' : 'Publish Quiz',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Question Card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q$index',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (question.source == 'ai') ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.accentDark),
                ],
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                ),
              ],
            ),
          ),

          // Question text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(question.options.length, (i) {
                final opt = question.options[i];
                final label = String.fromCharCode(65 + i); // A, B, C, D
                final isCorrect = opt == question.correctAnswer;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.successLight : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect ? AppColors.success : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCorrect ? AppColors.success : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isCorrect ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 13,
                            color: isCorrect ? AppColors.success : AppColors.textPrimary,
                            fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Explanation
          if (question.explanation != null && question.explanation!.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ── Edit Question Bottom Sheet ─────────────────────────────────────────────────

class _EditQuestionSheet extends StatefulWidget {
  final QuestionModel? question;
  final Future<void> Function(QuestionModel) onSave;

  const _EditQuestionSheet({this.question, required this.onSave});

  @override
  State<_EditQuestionSheet> createState() => _EditQuestionSheetState();
}

class _EditQuestionSheetState extends State<_EditQuestionSheet> {
  final _questionCtrl = TextEditingController();
  final _explanationCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    if (q != null) {
      _questionCtrl.text = q.question;
      _explanationCtrl.text = q.explanation ?? '';
      for (int i = 0; i < q.options.length && i < 4; i++) {
        _optionCtrls[i].text = q.options[i];
      }
      _correctIndex = q.options.indexOf(q.correctAnswer).clamp(0, 3);
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _explanationCtrl.dispose();
    for (final c in _optionCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_questionCtrl.text.trim().isEmpty) return;
    final options = _optionCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 options required.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final correctAnswer = _correctIndex < options.length
        ? options[_correctIndex]
        : options.first;

    final updated = QuestionModel(
      id: widget.question?.id ?? '',
      quizId: widget.question?.quizId ?? '',
      question: _questionCtrl.text.trim(),
      options: options,
      correctAnswer: correctAnswer,
      explanation: _explanationCtrl.text.trim(),
      order: widget.question?.order ?? 0,
      source: widget.question?.source ?? 'manual',
    );

    await widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.question == null ? 'Add Question' : 'Edit Question',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Question
            TextFormField(
              controller: _questionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Question *',
                hintText: 'Enter the quiz question...',
              ),
            ),
            const SizedBox(height: 16),

            // Options
            const Text(
              'Answer Options',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (i) {
              final label = String.fromCharCode(65 + i);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _correctIndex = i),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _correctIndex == i ? AppColors.success : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _correctIndex == i ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _optionCtrls[i],
                        decoration: InputDecoration(
                          hintText: 'Option $label',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tap the letter circle to mark as correct answer (currently: ${String.fromCharCode(65 + _correctIndex)})',
                style: const TextStyle(fontSize: 11, color: AppColors.success),
              ),
            ),

            const SizedBox(height: 12),

            // Explanation
            TextFormField(
              controller: _explanationCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Explanation (optional)',
                hintText: 'Why is this the correct answer?',
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.question == null ? 'Add Question' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
