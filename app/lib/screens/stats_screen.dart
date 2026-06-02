import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/premium_card.dart';
import '../providers/question_provider.dart';
import '../database/app_database.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => _StatsContent(stats: stats),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final StatsData stats;
  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracy = stats.totalAnswered > 0
        ? ((stats.totalCorrect / stats.totalAnswered) * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview stat cards
          Row(
            children: [
              Expanded(
                child: PremiumCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                      if (stats.totalQuestions > 0)
                        Text(
                          'of ${stats.totalQuestions}',
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                        'PASS RATE',
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        '${stats.totalCorrect}',
                        style: AppTextStyles.statMedium(
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 4),
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
          const SizedBox(height: 16),

          // Progress bar
          if (stats.totalQuestions > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: stats.totalAnswered / stats.totalQuestions,
                  backgroundColor: isDark
                      ? AppColors.backgroundSubtle
                      : AppColors.lightBackgroundSubtle,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accentPrimary),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(stats.totalAnswered / stats.totalQuestions * 100).toStringAsFixed(1)}% questions seen',
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Per theme breakdown
          Text(
            'PER THEME',
            style: AppTextStyles.label(
              color: isDark
                  ? AppColors.textTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
          const SizedBox(height: 12),
          ...stats.themeStats.map((ts) => _ThemeStatTile(stat: ts)),
        ],
      ),
    );
  }
}

class _ThemeStatTile extends StatelessWidget {
  final ThemeStat stat;

  const _ThemeStatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = stat.totalQuestions > 0
        ? stat.answeredQuestions / stat.totalQuestions
        : 0.0;
    final percentage = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PremiumCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${stat.themeNumber} ${stat.themeName}',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.accentLight,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? AppColors.backgroundSubtle
                      : AppColors.lightBackgroundSubtle,
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
