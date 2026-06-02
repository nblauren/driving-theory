import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import 'language_provider.dart';
import 'streak_provider.dart';

const _keyTriggeredMilestones = 'milestones_triggered';

enum Milestone {
  firstQuestion,
  tenQuestions,
  hundredQuestions,
  fiveHundredQuestions,
  perfectExam,
  fiftyPercentReady,
  eightyPercentReady,
  sevenDayStreak,
  thirtyDayStreak,
  allQuestionsSeen,
}

class MilestoneInfo {
  final String emoji;
  final String title;
  final String message;

  const MilestoneInfo({
    required this.emoji,
    required this.title,
    required this.message,
  });
}

const milestoneInfoMap = <Milestone, MilestoneInfo>{
  Milestone.firstQuestion: MilestoneInfo(
    emoji: '\u{1F31F}',
    title: 'First Question!',
    message: 'Your learning journey begins now!',
  ),
  Milestone.tenQuestions: MilestoneInfo(
    emoji: '\u{1F4AA}',
    title: '10 Questions Answered!',
    message: 'You\'re building momentum!',
  ),
  Milestone.hundredQuestions: MilestoneInfo(
    emoji: '\u{1F525}',
    title: '100 Questions!',
    message: 'Serious progress — keep going!',
  ),
  Milestone.fiveHundredQuestions: MilestoneInfo(
    emoji: '\u{1F3C6}',
    title: '500 Questions!',
    message: 'Half a thousand — you\'re dedicated!',
  ),
  Milestone.perfectExam: MilestoneInfo(
    emoji: '\u{1F3C6}',
    title: 'First Perfect Exam!',
    message: 'Zero penalty points — you\'re on track!',
  ),
  Milestone.fiftyPercentReady: MilestoneInfo(
    emoji: '\u{1F4C8}',
    title: '50% Ready!',
    message: 'Halfway to exam readiness!',
  ),
  Milestone.eightyPercentReady: MilestoneInfo(
    emoji: '\u{2705}',
    title: 'Exam Ready!',
    message: '80%+ readiness — time to book your exam!',
  ),
  Milestone.sevenDayStreak: MilestoneInfo(
    emoji: '\u{1F525}',
    title: '7-Day Streak!',
    message: 'A full week of daily study!',
  ),
  Milestone.thirtyDayStreak: MilestoneInfo(
    emoji: '\u{1F451}',
    title: '30-Day Streak!',
    message: 'One month of dedication — incredible!',
  ),
  Milestone.allQuestionsSeen: MilestoneInfo(
    emoji: '\u{1F389}',
    title: 'All Questions Seen!',
    message: 'You\'ve covered every single question!',
  ),
};

final milestoneProvider =
    StateNotifierProvider<MilestoneNotifier, Set<Milestone>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MilestoneNotifier(prefs);
});

class MilestoneNotifier extends StateNotifier<Set<Milestone>> {
  final SharedPreferences _prefs;

  MilestoneNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final str = _prefs.getString(_keyTriggeredMilestones);
    if (str == null) return;
    final list = (json.decode(str) as List).cast<String>();
    state = list
        .map((name) {
          try {
            return Milestone.values.byName(name);
          } catch (_) {
            return null;
          }
        })
        .whereType<Milestone>()
        .toSet();
  }

  bool isTriggered(Milestone m) => state.contains(m);

  /// Check and return any newly triggered milestones after a question answer.
  Future<List<Milestone>> checkAfterAnswer({
    required AppDatabase db,
    required StreakData streak,
  }) async {
    final newMilestones = <Milestone>[];

    final totalAnswered = await db.getTotalAnswered();

    if (!isTriggered(Milestone.firstQuestion) && totalAnswered >= 1) {
      newMilestones.add(Milestone.firstQuestion);
    }
    if (!isTriggered(Milestone.tenQuestions) && totalAnswered >= 10) {
      newMilestones.add(Milestone.tenQuestions);
    }
    if (!isTriggered(Milestone.hundredQuestions) && totalAnswered >= 100) {
      newMilestones.add(Milestone.hundredQuestions);
    }
    if (!isTriggered(Milestone.fiveHundredQuestions) && totalAnswered >= 500) {
      newMilestones.add(Milestone.fiveHundredQuestions);
    }

    // Streak milestones
    if (!isTriggered(Milestone.sevenDayStreak) && streak.currentStreak >= 7) {
      newMilestones.add(Milestone.sevenDayStreak);
    }
    if (!isTriggered(Milestone.thirtyDayStreak) && streak.currentStreak >= 30) {
      newMilestones.add(Milestone.thirtyDayStreak);
    }

    // Readiness milestones
    final readiness = await db.getReadinessPercentage();
    if (!isTriggered(Milestone.fiftyPercentReady) && readiness >= 50) {
      newMilestones.add(Milestone.fiftyPercentReady);
    }
    if (!isTriggered(Milestone.eightyPercentReady) && readiness >= 80) {
      newMilestones.add(Milestone.eightyPercentReady);
    }

    // All questions seen
    if (!isTriggered(Milestone.allQuestionsSeen)) {
      final totalQ = await db.getQuestionCount();
      if (totalAnswered >= totalQ && totalQ > 0) {
        newMilestones.add(Milestone.allQuestionsSeen);
      }
    }

    for (final m in newMilestones) {
      _trigger(m);
    }

    return newMilestones;
  }

  /// Check for perfect exam milestone.
  List<Milestone> checkAfterExam({required int totalPenalty}) {
    final newMilestones = <Milestone>[];
    if (!isTriggered(Milestone.perfectExam) && totalPenalty == 0) {
      newMilestones.add(Milestone.perfectExam);
      _trigger(Milestone.perfectExam);
    }
    return newMilestones;
  }

  void _trigger(Milestone m) {
    state = {...state, m};
    _save();
  }

  void _save() {
    final list = state.map((m) => m.name).toList();
    _prefs.setString(_keyTriggeredMilestones, json.encode(list));
  }
}
