import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import '../providers/database_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/language_provider.dart';
import '../providers/milestone_provider.dart';
import '../providers/streak_provider.dart';
import '../services/notification_service.dart';
import '../widgets/milestone_overlay.dart';
import '../widgets/question_card.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final QuestionFilter filter;
  final String title;

  const PracticeScreen({
    super.key,
    required this.filter,
    required this.title,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int _currentIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final ConfettiController _confettiController;

  final List<Set<String>> _allSelectedAnswers = [];
  final List<bool> _allSubmitted = [];
  final Map<String, bool> _bookmarkCache = {};

  final List<bool?> _allCorrect = [];
  bool _streakIncrementedThisSession = false;

  late FlutterTts _tts;
  bool _isTtsPlaying = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _audioPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      android: AudioContextAndroid(usageType: AndroidUsageType.notification),
    ));

    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isTtsPlaying = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isTtsPlaying = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTtsLanguage();
    });
  }

  void _updateTtsLanguage() {
    final language = ref.read(selectedLanguageProvider);
    _tts.setLanguage(language == AppLanguage.de ? 'de-DE' : 'en-US');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  void _ensureStateInitialized(int questionCount) {
    while (_allSelectedAnswers.length < questionCount) {
      _allSelectedAnswers.add(<String>{});
      _allSubmitted.add(false);
      _allCorrect.add(null);
    }
  }

  Set<String> get _selectedAnswers {
    if (_currentIndex >= _allSelectedAnswers.length) return {};
    return _allSelectedAnswers[_currentIndex];
  }

  bool get _submitted {
    if (_currentIndex >= _allSubmitted.length) return false;
    return _allSubmitted[_currentIndex];
  }

  Future<void> _loadBookmarkState(String questionId) async {
    if (_bookmarkCache.containsKey(questionId)) return;
    final db = ref.read(databaseProvider);
    final isBookmarked = await db.isQuestionBookmarked(questionId);
    if (mounted) {
      setState(() {
        _bookmarkCache[questionId] = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark(String questionId) async {
    final db = ref.read(databaseProvider);
    await db.toggleBookmark(questionId);
    if (mounted) {
      setState(() {
        _bookmarkCache[questionId] = !(_bookmarkCache[questionId] ?? false);
      });
    }
  }

  Future<void> _toggleTts(QuestionModel question) async {
    if (_isTtsPlaying) {
      await _tts.stop();
      setState(() => _isTtsPlaying = false);
    } else {
      _updateTtsLanguage();
      setState(() => _isTtsPlaying = true);
      final buffer = StringBuffer(question.questionText);
      for (final opt in question.options) {
        buffer.write('. ${opt.text}');
      }
      await _tts.speak(buffer.toString());
    }
  }

  void _stopTts() {
    if (_isTtsPlaying) {
      _tts.stop();
      _isTtsPlaying = false;
    }
  }

  Future<bool> _confirmLeaveQuestion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this question?'),
        content: const Text(
            'You haven\'t submitted your answer yet. Do you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionListProvider(widget.filter));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(selectedLanguageProvider, (_, __) {
      _stopTts();
      _updateTtsLanguage();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 64,
                        color: AppColors.accentLight),
                    const SizedBox(height: 16),
                    Text(
                      _emptyMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          _ensureStateInitialized(questions.length);

          if (_currentIndex >= questions.length) {
            return _buildCompletionScreen(context);
          }

          final question = questions[_currentIndex];
          _loadBookmarkState(question.questionId);
          return _buildQuestionView(context, question, questions.length);
        },
      ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              gravity: 0.2,
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _emptyMessage {
    switch (widget.filter) {
      case QuestionFilter.dueForReview:
        return 'No questions due for review.\nGreat job staying on top!';
      case QuestionFilter.unseen:
        return 'You\'ve seen all questions!';
      case QuestionFilter.incorrect:
        return 'No incorrect answers yet.\nKeep it up!';
      case QuestionFilter.bookmarked:
        return 'No bookmarked questions.\nTap the bookmark icon to flag questions.';
      case QuestionFilter.all:
        return 'No questions available.';
      case QuestionFilter.dailyChallenge:
        return 'No daily challenge questions available.';
    }
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final isDailyChallenge = widget.filter == QuestionFilter.dailyChallenge;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int correctCount = 0;
    int totalPointsLost = 0;
    if (isDailyChallenge) {
      final questions =
          ref.read(questionListProvider(widget.filter)).valueOrNull ?? [];
      for (int i = 0; i < _allCorrect.length && i < questions.length; i++) {
        if (_allCorrect[i] == true) {
          correctCount++;
        } else if (_allCorrect[i] == false) {
          totalPointsLost += questions[i].points;
        }
      }
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successSubtle,
                border: Border.all(color: AppColors.success),
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              isDailyChallenge ? 'Daily Challenge Complete!' : 'Session Complete!',
              style: AppTextStyles.statMedium(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
            if (isDailyChallenge) ...[
              const SizedBox(height: 16),
              Text(
                '$correctCount / ${_allCorrect.length} correct',
                style: AppTextStyles.statSmall(color: AppColors.accentLight),
              ),
              if (totalPointsLost > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$totalPointsLost points lost',
                    style: AppTextStyles.bodySmall(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _getDailyChallengeMessage(correctCount, _allCorrect.length),
                style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_streakIncrementedThisSession && streak.currentStreak > 0) ...[
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.warningSubtle,
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${streak.currentStreak} day streak — keep it up!',
                      style: AppTextStyles.bodySmall(color: AppColors.warning)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDailyChallengeMessage(int correct, int total) {
    final ratio = total > 0 ? correct / total : 0.0;
    if (ratio >= 1.0) return 'Perfect score! You nailed it!';
    if (ratio >= 0.8) return 'Excellent work! Almost flawless!';
    if (ratio >= 0.6) return 'Good effort! Keep reviewing your weak spots.';
    if (ratio >= 0.4) return 'Not bad — practice makes perfect!';
    return 'Keep studying, you\'ll get there!';
  }

  Widget _buildQuestionView(
      BuildContext context, QuestionModel question, int total) {
    final isNumericAnswer = question.options.isEmpty;
    final ttsEnabled = ref.watch(ttsEnabledProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onHorizontalDragEnd: (details) async {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200) {
          if (!_submitted && _selectedAnswers.isNotEmpty) {
            final shouldLeave = await _confirmLeaveQuestion();
            if (!shouldLeave) return;
          }
          _stopTts();
          if (_currentIndex < total - 1) {
            setState(() => _currentIndex++);
          }
        } else if (details.primaryVelocity! > 200) {
          if (!_submitted && _selectedAnswers.isNotEmpty) {
            final shouldLeave = await _confirmLeaveQuestion();
            if (!shouldLeave) return;
          }
          _stopTts();
          if (_currentIndex > 0) {
            setState(() => _currentIndex--);
          }
        }
      },
      child: Column(
        children: [
          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(end: (_currentIndex + 1) / total),
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
                selectedAnswers: _selectedAnswers,
                submitted: _submitted,
                isNumericAnswer: isNumericAnswer,
                isBookmarked: _bookmarkCache[question.questionId] ?? false,
                onBookmarkToggle: () =>
                    _toggleBookmark(question.questionId),
                isTtsPlaying: _isTtsPlaying,
                onTtsToggle: ttsEnabled ? () => _toggleTts(question) : null,
                onAnswerToggle: _submitted
                    ? null
                    : (letter) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (_selectedAnswers.contains(letter)) {
                            _selectedAnswers.remove(letter);
                          } else {
                            _selectedAnswers.add(letter);
                          }
                        });
                      },
                onNumericSubmit: isNumericAnswer && !_submitted
                    ? (value) {
                        setState(() {
                          _selectedAnswers.clear();
                          _selectedAnswers.add(value);
                        });
                      }
                    : null,
              ),
            ),
          ),
          // Bottom action bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${_currentIndex + 1} / $total',
                    style: AppTextStyles.label(
                      color: isDark
                          ? AppColors.textTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                  const Spacer(),
                  if (!_submitted)
                    SizedBox(
                      width: 160,
                      child: FilledButton(
                        onPressed:
                            _selectedAnswers.isEmpty ? null : _handleSubmit,
                        child: const Text('Submit Answer'),
                      ),
                    )
                  else
                    SizedBox(
                      width: 120,
                      child: FilledButton(
                        onPressed: _handleNext,
                        child: Text(
                            _currentIndex < total - 1 ? 'Next' : 'Finish'),
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

  void _handleSubmit() async {
    final questions =
        ref.read(questionListProvider(widget.filter)).valueOrNull ?? [];
    if (_currentIndex >= questions.length) return;

    final question = questions[_currentIndex];
    final correctLetters =
        question.correctAnswers.map((a) => a.letter).toSet();

    final isCorrect = _selectedAnswers.length == correctLetters.length &&
        _selectedAnswers.containsAll(correctLetters);

    final db = ref.read(databaseProvider);
    final syncService = ref.read(firebaseSyncServiceProvider);
    await recordAnswer(db, question.questionId, isCorrect,
        syncService: syncService);

    final streakIncremented =
        ref.read(streakProvider.notifier).recordStudyDay();
    if (streakIncremented) {
      _streakIncrementedThisSession = true;
      NotificationService().onUserStudied();
    }

    if (widget.filter == QuestionFilter.dailyChallenge) {
      ref.read(dailyChallengeProvider.notifier).markAnswered(question.questionId);
    }

    ref.invalidate(readinessProvider);

    _audioPlayer.play(AssetSource(
      isCorrect ? 'sounds/correct.wav' : 'sounds/wrong.wav',
    ));

    setState(() {
      _allSubmitted[_currentIndex] = true;
      _allCorrect[_currentIndex] = isCorrect;
    });

    if (isCorrect && _currentIndex == questions.length - 1) {
      _confettiController.play();
    }

    _checkMilestones();
  }

  Future<void> _checkMilestones() async {
    final db = ref.read(databaseProvider);
    final streak = ref.read(streakProvider);
    final newMilestones = await ref
        .read(milestoneProvider.notifier)
        .checkAfterAnswer(db: db, streak: streak);

    if (newMilestones.isNotEmpty && mounted) {
      await showMilestoneQueue(context, newMilestones);
    }
  }

  void _handleNext() {
    _stopTts();
    setState(() {
      _currentIndex++;
    });
  }
}
