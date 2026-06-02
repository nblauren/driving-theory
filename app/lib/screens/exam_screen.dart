import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/premium_card.dart';
import '../models/question_model.dart';
import '../providers/milestone_provider.dart';
import '../providers/question_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/milestone_overlay.dart';
import '../widgets/question_card.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  List<QuestionModel>? _questions;
  List<Set<String>>? _answers;
  bool _hadEnoughQuestions = true;
  int _currentIndex = 0;
  ExamResult? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    final db = ref.read(databaseProvider);
    final localizedMap = await ref.read(localizedQuestionMapProvider.future);
    final result = await generateExam(db);
    setState(() {
      _questions = result.questions
          .map((q) => localizeQuestion(q, localizedMap))
          .toList();
      _answers = List.generate(result.questions.length, (_) => <String>{});
      _hadEnoughQuestions = result.hadEnoughQuestions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Simulation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_result != null) {
      return _buildResultScreen(context);
    }

    final questions = _questions!;
    final question = questions[_currentIndex];
    final currentAnswers = _answers![_currentIndex];
    final isNumericAnswer = question.options.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Exam — ${_currentIndex + 1}/${questions.length}'),
        actions: [
          if (!_hadEnoughQuestions)
            const Tooltip(
              message: 'Not enough questions per category — using random mix',
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.warning_amber, color: AppColors.warning),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: (_currentIndex + 1) / questions.length),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, _) => ClipRRect(
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: isDark
                      ? AppColors.backgroundSubtle
                      : AppColors.lightBackgroundSubtle,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accentPrimary),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: QuestionCard(
                question: question,
                selectedAnswers: currentAnswers,
                submitted: false,
                isNumericAnswer: isNumericAnswer,
                onAnswerToggle: (letter) {
                  setState(() {
                    if (currentAnswers.contains(letter)) {
                      currentAnswers.remove(letter);
                    } else {
                      currentAnswers.add(letter);
                    }
                  });
                },
                onNumericSubmit: isNumericAnswer
                    ? (value) {
                        setState(() {
                          currentAnswers.clear();
                          currentAnswers.add(value);
                        });
                      }
                    : null,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    SizedBox(
                      width: 110,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentIndex--);
                        },
                        child: const Text('Previous'),
                      ),
                    ),
                  const Spacer(),
                  if (_currentIndex < questions.length - 1)
                    SizedBox(
                      width: 110,
                      child: FilledButton(
                        onPressed: () {
                          setState(() => _currentIndex++);
                        },
                        child: const Text('Next'),
                      ),
                    )
                  else
                    SizedBox(
                      width: 140,
                      child: FilledButton(
                        onPressed: _finishExam,
                        child: const Text('Finish Exam'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishExam() {
    final unanswered = _answers!
        .asMap()
        .entries
        .where((e) => e.value.isEmpty)
        .map((e) => e.key + 1)
        .toList();

    if (unanswered.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unanswered Questions'),
          content: Text(
            'You have ${unanswered.length} unanswered question(s). '
            'Submit anyway? Unanswered questions count as wrong.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Go Back'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _scoreAndShow();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else {
      _scoreAndShow();
    }
  }

  void _scoreAndShow() {
    final result =
        scoreExam(_questions!, _answers!, _hadEnoughQuestions);

    final milestones = ref
        .read(milestoneProvider.notifier)
        .checkAfterExam(totalPenalty: result.totalPenalty);

    setState(() {
      _result = result;
    });

    if (milestones.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showMilestoneQueue(context, milestones);
        }
      });
    }
  }

  Widget _buildResultScreen(BuildContext context) {
    final result = _result!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort wrong answers first
    final sortedQuestions = List<MapEntry<int, ExamQuestion>>.from(
      result.questions.asMap().entries,
    )..sort((a, b) {
        if (a.value.isCorrect == b.value.isCorrect) return a.key.compareTo(b.key);
        return a.value.isCorrect ? 1 : -1;
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: result.passed ? AppColors.successSubtle : AppColors.errorSubtle,
                border: Border.all(
                  color: result.passed ? AppColors.success : AppColors.error,
                ),
              ),
              child: Icon(
                result.passed ? Icons.check : Icons.close,
                size: 28,
                color: result.passed ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.passed ? 'Passed!' : 'Failed',
              style: AppTextStyles.statMedium(
                color: result.passed ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mock Exam · ${result.questions.length} Questions',
              style: AppTextStyles.label(
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
            ),
            if (!result.hadEnoughQuestions) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Not enough questions per category. Used random selection.',
                        style: AppTextStyles.bodySmall(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Score cards row
            Row(
              children: [
                Expanded(
                  child: PremiumCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '${result.totalPenalty}',
                          style: AppTextStyles.statMedium(
                            color: result.totalPenalty <= 10
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PENALTY',
                          style: AppTextStyles.labelSmall(
                            color: isDark
                                ? AppColors.textTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PremiumCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '${result.fivePointWrong}',
                          style: AppTextStyles.statMedium(
                            color: result.fivePointWrong < 2
                                ? AppColors.warning
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '5PT WRONG',
                          style: AppTextStyles.labelSmall(
                            color: isDark
                                ? AppColors.textTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PremiumCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '${result.questions.where((q) => q.isCorrect).length}',
                          style: AppTextStyles.statMedium(
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CORRECT',
                          style: AppTextStyles.labelSmall(
                            color: isDark
                                ? AppColors.textTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Divider
            Container(
              height: 1,
              color: isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle,
            ),
            const SizedBox(height: 16),
            // Review answers section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'REVIEW ANSWERS',
                style: AppTextStyles.labelSmall(
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...sortedQuestions.map((entry) {
              final i = entry.key;
              final eq = entry.value;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _ExamQuestionReviewScreen(
                        examQuestion: eq,
                        questionNumber: i + 1,
                        totalQuestions: result.questions.length,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // Colored dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: eq.isCorrect ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${i + 1}. ${eq.question.questionText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall(
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${eq.question.points}pt',
                        style: AppTextStyles.labelSmall(
                          color: eq.isCorrect ? AppColors.success : AppColors.error,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            // CTAs
            if (result.questions.any((q) => !q.isCorrect))
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Navigate to first wrong answer
                    final firstWrong = result.questions
                        .asMap()
                        .entries
                        .firstWhere((e) => !e.value.isCorrect);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ExamQuestionReviewScreen(
                          examQuestion: firstWrong.value,
                          questionNumber: firstWrong.key + 1,
                          totalQuestions: result.questions.length,
                        ),
                      ),
                    );
                  },
                  child: const Text('Review Wrong Answers'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- Exam question review detail screen ---

class _ExamQuestionReviewScreen extends ConsumerStatefulWidget {
  final ExamQuestion examQuestion;
  final int questionNumber;
  final int totalQuestions;

  const _ExamQuestionReviewScreen({
    required this.examQuestion,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  ConsumerState<_ExamQuestionReviewScreen> createState() =>
      _ExamQuestionReviewScreenState();
}

class _ExamQuestionReviewScreenState
    extends ConsumerState<_ExamQuestionReviewScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final db = ref.read(databaseProvider);
    final bookmarked =
        await db.isQuestionBookmarked(widget.examQuestion.question.questionId);
    if (mounted) setState(() => _isBookmarked = bookmarked);
  }

  Future<void> _toggleBookmark() async {
    final db = ref.read(databaseProvider);
    await db.toggleBookmark(widget.examQuestion.question.questionId);
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = widget.examQuestion.question;
    final correctLetters = q.correctAnswers.map((a) => a.letter).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${widget.questionNumber} / ${widget.totalQuestions}'),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.warning : null,
            ),
            onPressed: _toggleBookmark,
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result badge
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.examQuestion.isCorrect
                        ? AppColors.successSubtle
                        : AppColors.errorSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.examQuestion.isCorrect
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color: widget.examQuestion.isCorrect
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.examQuestion.isCorrect ? 'Correct' : 'Wrong',
                        style: AppTextStyles.label(
                          color: widget.examQuestion.isCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${q.points} ${q.points == 1 ? "Point" : "Points"}',
                    style: AppTextStyles.label(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  q.questionId,
                  style: AppTextStyles.labelSmall(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Images
            if (q.localImagePaths.isNotEmpty)
              ...q.localImagePaths.map((imgPath) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: InteractiveViewer(
                        maxScale: 4.0,
                        child: Image.asset(
                          'assets/$imgPath',
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  )),
            // Question text
            Text(
              q.questionText,
              style: AppTextStyles.body(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 20),
            // Answer options
            ...q.options.map((option) {
              final isCorrect = correctLetters.contains(option.letter);
              final wasSelected =
                  widget.examQuestion.selectedAnswers.contains(option.letter);
              final selectedCorrectly = isCorrect && wasSelected;
              final selectedWrongly = !isCorrect && wasSelected;
              final missedCorrect = isCorrect && !wasSelected;

              Color bgColor;
              Color borderColor;
              if (selectedCorrectly) {
                bgColor = AppColors.successSubtle;
                borderColor = AppColors.success;
              } else if (selectedWrongly) {
                bgColor = AppColors.errorSubtle;
                borderColor = AppColors.error;
              } else if (missedCorrect) {
                bgColor = AppColors.warningSubtle;
                borderColor = AppColors.warning;
              } else {
                bgColor = isDark ? AppColors.backgroundSubtle : AppColors.lightBackgroundSubtle;
                borderColor = isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle;
              }

              Color circleBg;
              if (selectedCorrectly) {
                circleBg = AppColors.success;
              } else if (selectedWrongly) {
                circleBg = AppColors.error;
              } else if (missedCorrect) {
                circleBg = AppColors.warning;
              } else {
                circleBg = isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleBg,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option.letter.replaceAll('.', ''),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: (isCorrect || wasSelected)
                                ? Colors.white
                                : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.text,
                              style: AppTextStyles.body(
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (isCorrect || wasSelected)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (wasSelected)
                                      _AnswerTag(
                                        label: 'Your answer',
                                        color: isCorrect
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    if (isCorrect)
                                      _AnswerTag(
                                        label: 'Correct answer',
                                        color: AppColors.success,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (selectedCorrectly)
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 20)
                      else if (selectedWrongly)
                        const Icon(Icons.cancel,
                            color: AppColors.error, size: 20)
                      else if (missedCorrect)
                        const Icon(Icons.error_outline,
                            color: AppColors.warning, size: 20),
                    ],
                  ),
                ),
              );
            }),
            // Explanation
            if (q.comment.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPLANATION',
                      style: AppTextStyles.labelSmall(
                        color: isDark
                            ? AppColors.textTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.comment,
                      style: AppTextStyles.bodySmall(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerTag extends StatelessWidget {
  final String label;
  final Color color;

  const _AnswerTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: color)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
