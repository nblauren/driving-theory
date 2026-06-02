import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/premium_card.dart';
import '../providers/database_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/language_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/question_provider.dart';
import '../services/notification_service.dart';
import 'practice_screen.dart';
import 'exam_screen.dart';
import 'account_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOnLaunch();
      _setupNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncOnLaunch();
      ref.invalidate(readinessProvider);
    }
  }

  Future<void> _setupNotifications() async {
    final notif = NotificationService();
    await notif.requestPermission();
    await notif.scheduleStreakReminder();
  }

  Future<void> _syncOnLaunch() async {
    final syncService = ref.read(firebaseSyncServiceProvider);
    if (!syncService.isLoggedIn) return;

    ref.read(syncInProgressProvider.notifier).state = true;
    try {
      final db = ref.read(databaseProvider);
      await syncService.pullAndMerge(db);
    } catch (e) {
      log('Sync on launch failed: $e', name: 'HomeScreen');
    } finally {
      if (mounted) {
        ref.read(syncInProgressProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seeded = ref.watch(databaseSeededProvider);
    final authState = ref.watch(authStateProvider);
    final syncing = ref.watch(syncInProgressProvider);
    final language = ref.watch(selectedLanguageProvider);

    return Scaffold(
      body: SafeArea(
        child: seeded.when(
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading questions...'),
              ],
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (_) => _HomeContent(
            syncing: syncing,
            language: language,
            authState: authState,
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  final bool syncing;
  final AppLanguage language;
  final AsyncValue authState;

  const _HomeContent({
    required this.syncing,
    required this.language,
    required this.authState,
  });

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  static const _itemCount = 7;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200 + _itemCount * 80),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _fadeFor(int index) {
    final start = (index * 80) / (_staggerController.duration!.inMilliseconds);
    final end =
        (index * 80 + 200) / (_staggerController.duration!.inMilliseconds);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start.clamp(0, 1), end.clamp(0, 1), curve: Curves.easeOut),
    );
  }

  Widget _staggeredItem(int index, Widget child) {
    final fade = _fadeFor(index);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(fade),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readiness = ref.watch(readinessProvider);
    final streak = ref.watch(streakProvider);
    final challenge = ref.watch(dailyChallengeProvider);
    final prediction = ref.watch(predictionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int itemIndex = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status area: greeting + user actions ──
          _staggeredItem(
            itemIndex++,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'German Driving Theory Trainer',
                        style: AppTextStyles.bodySmall(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fahrprüfung Klasse B',
                        style: AppTextStyles.statMedium(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Language toggle
                SubtleCard(
                  onTap: () {
                    final notifier = ref.read(selectedLanguageProvider.notifier);
                    notifier.setLanguage(
                        widget.language == AppLanguage.en
                            ? AppLanguage.de
                            : AppLanguage.en);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    widget.language == AppLanguage.en ? 'EN' : 'DE',
                    style: AppTextStyles.label(color: AppColors.accentLight),
                  ),
                ),
                const SizedBox(width: 8),
                // Account
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.backgroundSubtle
                          : AppColors.lightBackgroundSubtle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle
                            : AppColors.lightBorderSubtle,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                if (widget.syncing) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Exam Readiness (AccentCard) ──
          _staggeredItem(
            itemIndex++,
            readiness.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (percentage) => _ReadinessIndicator(percentage: percentage),
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats row: 3 PremiumCards ──
          _staggeredItem(
            itemIndex++,
            _StatsRow(streak: streak),
          ),
          const SizedBox(height: 16),

          // ── Daily Challenge card ──
          if (challenge != null)
            _staggeredItem(itemIndex++, _DailyChallengeCard(challenge: challenge)),
          if (challenge != null) const SizedBox(height: 12),

          // ── Prediction card ──
          _staggeredItem(
            itemIndex++,
            prediction.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (data) => _PredictionCard(data: data),
            ),
          ),
          const SizedBox(height: 16),

          // ── Menu cards ──
          _staggeredItem(
            itemIndex++,
            _MenuCard(
              icon: Icons.play_arrow_rounded,
              title: 'Practice',
              subtitle: 'Study with spaced repetition',
              onTap: () => _showPracticeOptions(context, ref),
            ),
          ),
          const SizedBox(height: 12),
          _staggeredItem(
            itemIndex++,
            _MenuCard(
              icon: Icons.assignment_rounded,
              title: 'Exam Simulation',
              subtitle: '30 questions — pass or fail',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExamScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showPracticeOptions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderMedium : AppColors.lightBorderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _BottomSheetOption(
              icon: Icons.refresh,
              iconColor: AppColors.accentLight,
              title: 'Due for Review',
              subtitle: 'Spaced repetition queue',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PracticeScreen(
                      filter: QuestionFilter.dueForReview,
                      title: 'Due for Review',
                    ),
                  ),
                );
              },
            ),
            _BottomSheetOption(
              icon: Icons.visibility_off,
              iconColor: AppColors.accentLight,
              title: 'Unseen Questions',
              subtitle: 'Questions you haven\'t seen yet',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PracticeScreen(
                      filter: QuestionFilter.unseen,
                      title: 'Unseen Questions',
                    ),
                  ),
                );
              },
            ),
            _BottomSheetOption(
              icon: Icons.close,
              iconColor: AppColors.error,
              title: 'Mistakes',
              subtitle: 'Questions answered incorrectly',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PracticeScreen(
                      filter: QuestionFilter.incorrect,
                      title: 'Mistakes',
                    ),
                  ),
                );
              },
            ),
            _BottomSheetOption(
              icon: Icons.bookmark,
              iconColor: AppColors.warning,
              title: 'Bookmarked',
              subtitle: 'Questions you flagged for review',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PracticeScreen(
                      filter: QuestionFilter.bookmarked,
                      title: 'Bookmarked',
                    ),
                  ),
                );
              },
            ),
            _BottomSheetOption(
              icon: Icons.list,
              iconColor: AppColors.accentLight,
              title: 'All Questions',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PracticeScreen(
                      filter: QuestionFilter.all,
                      title: 'All Questions',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _BottomSheetOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}

/// Traffic-light readiness indicator as AccentCard.
class _ReadinessIndicator extends StatelessWidget {
  final double percentage;

  const _ReadinessIndicator({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final int rounded = percentage.round();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color activeColor;
    int activeIndex;
    if (percentage >= 80) {
      activeColor = AppColors.success;
      activeIndex = 2;
    } else if (percentage >= 50) {
      activeColor = AppColors.warning;
      activeIndex = 1;
    } else {
      activeColor = AppColors.error;
      activeIndex = 0;
    }

    final dotColors = [AppColors.error, AppColors.warning, AppColors.success];

    return AccentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'EXAM READINESS',
                style: AppTextStyles.labelSmall(
                  color: isDark
                      ? AppColors.textTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              const Spacer(),
              // Traffic light dots
              ...List.generate(3, (i) {
                final isActive = i == activeIndex;
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? dotColors[i] : dotColors[i].withValues(alpha: 0.2),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: dotColors[i].withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$rounded%',
            style: AppTextStyles.statLarge(color: activeColor).copyWith(fontSize: 36),
          ),
          const SizedBox(height: 8),
          // Thin progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: isDark
                    ? AppColors.backgroundSubtle
                    : AppColors.lightBackgroundSubtle,
                valueColor: AlwaysStoppedAnimation(activeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats row with 3 equal PremiumCards.
class _StatsRow extends ConsumerWidget {
  final StreakData streak;
  const _StatsRow({required this.streak});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final accuracy = stats.totalAnswered > 0
            ? ((stats.totalCorrect / stats.totalAnswered) * 100).round()
            : 0;

        return Row(
          children: [
            Expanded(
              child: PremiumCard(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      '${streak.currentStreak}',
                      style: AppTextStyles.statMedium(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DAY STREAK',
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
                      '${stats.totalAnswered}',
                      style: AppTextStyles.statMedium(
                        color: AppColors.accentLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ANSWERED',
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
                      '$accuracy%',
                      style: AppTextStyles.statMedium(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ACCURACY',
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
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGlow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentLight, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading2(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                )),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionData data;
  const _PredictionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String text;
    IconData icon;

    if (data.alreadyReady) {
      icon = Icons.check_circle_outline;
      text = 'You\'re ready — time to book your exam!';
    } else if (data.notEnoughData) {
      icon = Icons.calendar_today;
      text = 'Study a few more days to get your prediction';
    } else if (data.tooFarOut) {
      icon = Icons.calendar_today;
      text = 'Keep studying daily to get an accurate prediction';
    } else if (data.predictedDate != null) {
      icon = Icons.calendar_today;
      final d = data.predictedDate!;
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      text = 'Exam ready by approx. ${d.day} ${months[d.month - 1]}';
    } else {
      return const SizedBox.shrink();
    }

    return SubtleCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final DailyChallengeData challenge;
  const _DailyChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title;
    String subtitle;

    switch (challenge.status) {
      case DailyChallengeStatus.notStarted:
        title = 'Daily Challenge';
        subtitle = '10 questions ready';
      case DailyChallengeStatus.inProgress:
        title = 'Daily Challenge';
        subtitle = '${challenge.answeredCount}/10 done';
      case DailyChallengeStatus.complete:
        title = 'Daily Challenge complete';
        subtitle = 'Come back tomorrow';
    }

    return PremiumCard(
      onTap: challenge.status == DailyChallengeStatus.complete
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PracticeScreen(
                    filter: QuestionFilter.dailyChallenge,
                    title: 'Daily Challenge',
                  ),
                ),
              ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            challenge.status == DailyChallengeStatus.complete
                ? Icons.check_circle_rounded
                : Icons.emoji_events_rounded,
            color: challenge.status == DailyChallengeStatus.complete
                ? AppColors.success
                : AppColors.warning,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading2(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (challenge.status != DailyChallengeStatus.complete)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGlow,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.accentLight,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
